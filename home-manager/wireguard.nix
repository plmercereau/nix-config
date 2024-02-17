{
  config,
  pkgs,
  agenix,
  lib,
  nixosConfigurations,
  ...
}:
with lib; let
  bastion = (findFirst (machine: machine.config.settings.networking.vpn.bastion.enable) (throw "bastion not found") (attrValues nixosConfigurations)).config;
  inherit (bastion.settings.networking.vpn.bastion) cidr domain port;
  inherit (config.home) username;
  inherit (bastion.settings.networking.vpn.bastion.extraPeers.${username}) id;

  wgConfig = pkgs.writeText "wg0.conf" (generators.toINI {} {
    Interface = {
      Address = bastion.lib.vpn.machineIp cidr id;
      PostUp = pkgs.writeShellScript "postup.sh" ''
        # Add the route to the VPN network
        mkdir -p /etc/resolver
        cat << EOF > /etc/resolver/vpn
        port 53
        domain ${domain}
        search ${domain}
        nameserver ${bastion.lib.vpn.ip}
        EOF
      '';
      PostDown = pkgs.writeShellScript "postdown.sh" ''
        rm -f /etc/resolver/vpn
      '';
    };
    Peer = {
      PublicKey = bastion.settings.networking.vpn.publicKey;
      AllowedIPs = cidr;
      Endpoint = "${bastion.settings.networking.publicIP}:${toString port}";
      PersistentKeepalive = 25;
    };
  });
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
      cp ${wgConfig} ${path}
      chmod u+w ${path}
      ${pkgs.crudini}/bin/crudini --set ${path} Interface PrivateKey $(${pkgs.coreutils}/bin/cat ${config.age.secrets.vpn.path})
    '';
    wgup = pkgs.writeScriptBin "wgup" ''
      ${createConfig}
      sudo wg-quick up ${path}
    '';
    wgdown = pkgs.writeScriptBin "wgdown" ''
      ${createConfig}
      sudo wg-quick down ${path}
      ${deleteConfig}
    '';
  in [
    wgup
    wgdown
  ];
}
