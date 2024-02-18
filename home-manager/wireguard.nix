{
  config,
  pkgs,
  agenix,
  lib,
  nixosConfigurations,
  ...
}:
with lib; let
  interface = "wg0";
  bastion = (findFirst (machine: machine.config.settings.networking.vpn.bastion.enable) (throw "bastion not found") (attrValues nixosConfigurations)).config;
  inherit (bastion.settings.networking.vpn.bastion) port;
  inherit (config.home) username;
  inherit (bastion.settings.networking.vpn.bastion.extraPeers.${username}) id;

  hostNetwork = bastion.settings.networking.vpn.bastion;
  k8sNetwork = bastion.settings.services.kubernetes.vpn;

  baseConfig = {
    Interface = {
      Address = [(bastion.lib.vpn.machineIp hostNetwork.cidr id) (bastion.lib.vpn.machineIp k8sNetwork.cidr id)];
      # TODO if we want to make this home-manager module more generic, postup and postdown should work for other non-macOS systems
      PostUp = let
        # TODO for some reason, ${config.age.secrets.vpn.path} does not point to the right place when used in PostUp
        privateKeyPath = "/run/agenix/vpn";
      in
        pkgs.writeShellScript "postup.sh" ''
          ${pkgs.wireguard-tools}/bin/wg set $(${pkgs.wireguard-tools}/bin/wg show interfaces) private-key ${privateKeyPath}
          # Add the route to the VPN network
          mkdir -p /etc/resolver
          cat << EOF > /etc/resolver/${hostNetwork.domain}
          port 53
          domain ${hostNetwork.domain}
          search ${hostNetwork.domain}
          nameserver ${bastion.lib.vpn.machineIp hostNetwork.cidr bastion.settings.networking.vpn.id}
          EOF
          cat << EOF > /etc/resolver/${k8sNetwork.domain}
          port 53
          domain ${k8sNetwork.domain}
          search ${k8sNetwork.domain}
          nameserver ${bastion.lib.vpn.machineIp k8sNetwork.cidr bastion.settings.networking.vpn.id}
          EOF
        '';
      PostDown = pkgs.writeShellScript "postdown.sh" ''
        rm -f /etc/resolver/${hostNetwork.domain}
        rm -f /etc/resolver/${k8sNetwork.domain}
      '';
    };
    Peer = {
      PublicKey = bastion.settings.networking.vpn.publicKey;
      AllowedIPs = [hostNetwork.cidr k8sNetwork.cidr];
      Endpoint = "${bastion.settings.networking.publicIP}:${toString port}";
      PersistentKeepalive = 25;
    };
  };

  customToINI = generators.toINI {
    mkKeyValue = generators.mkKeyValueDefault {
      mkValueString = v:
        if isList v
        then concatStringsSep "," v
        else if isString v
        then v
        # and delegates all other values to the default generator
        else generators.mkValueStringDefault {} v;
    } " = ";
  };
in {
  imports = [agenix.homeManagerModules.default];
  age.identityPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
  age.secrets.vpn.file = ../users + "/${username}.vpn.age";

  home.packages = let
    path = "$HOME/.config/wg0.conf";
    deleteConfig = pkgs.writeScript "delete-config" ''
      rm -f ${path}
    '';
    createConfig = pkgs.writeScript "create-config" ''
      ${deleteConfig}
      mkdir -p $(dirname ${path})
      ${pkgs.coreutils}/bin/install ${pkgs.writeText "wg0.conf" (customToINI baseConfig)} ${path}
    '';
    wgup = pkgs.writeScriptBin "wgup" ''
      ${createConfig}
      sudo ${pkgs.wireguard-tools}/bin/wg-quick down ${path}
      sudo ${pkgs.wireguard-tools}/bin/wg-quick up ${path}
    '';
    wgdown = pkgs.writeScriptBin "wgdown" ''
      ${createConfig}
      sudo ${pkgs.wireguard-tools}/bin/wg-quick down ${path}
      ${deleteConfig}
    '';
  in [
    wgup
    wgdown
  ];
}
