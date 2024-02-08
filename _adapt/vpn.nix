{
  config,
  lib,
  pkgs,
  cluster,
  ...
}:
with lib; let
  servers = filterAttrs (_: cfg: cfg.lib.vpn.isServer) cluster.hosts;
in {
  networking.wg-quick.interfaces.${vpn.interface} = {
    address = [vpnLib.ipWithMask]; # TODO
    peers =
      mkDefault
      (mapAttrsToList (_: cfg: let
          netSettings = cfg.settings.networking;
        in {
          inherit (netSettings.vpn) publicKey;
          allowedIPs = [vpn.cidr]; # TODO
          endpoint = "${netSettings.publicIP}:${builtins.toString netSettings.vpn.bastion.port}";
          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        })
        servers);
    postUp = ''
      ${concatStringsSep "\n" (mapAttrsToList (_: cfg: let
          vpn = cfg.settings.networking.vpn;
        in ''
          # Add the route to the VPN network
          mkdir -p /etc/resolver
          cat << EOF > /etc/resolver/${vpn.domain}
          port 53
          domain ${vpn.domain}
          search ${vpn.domain}
          nameserver ${cfg.lib.vpn.ip}
          EOF
        '')
        servers)}
    '';

    postDown = ''
      ${concatStringsSep "\n" (mapAttrsToList (_: cfg: ''
          rm -f /etc/resolver/${vpn.domain}
        '')
        servers)}

    '';
  };
}
