{
  config,
  lib,
  cluster,
  ...
}:
with lib; let
  inherit (cluster) hosts;
in {
  # Load SSH known hosts
  programs.ssh.knownHosts =
    lib.mapAttrs (name: cfg: let
      inherit (cfg.settings) sshPublicKey;
      inherit (cfg.settings.networking) publicIP localIP vpn;
    in {
      hostNames =
        lib.optionals vpn.enable [cfg.lib.vpn.ip name "${name}.${vpn.domain}"]
        ++ lib.optional (publicIP != null) publicIP
        ++ lib.optional (localIP != null) localIP;
      publicKey = sshPublicKey;
    })
    hosts;

  environment.etc."ssh/sshd_config.d/300-hosts.conf".text = builtins.concatStringsSep "\n" (lib.mapAttrsToList (
      name: cfg: let
        inherit (cfg.settings.networking) publicIP publicDomain localIP localDomain vpn;
      in
        # Use the local IP if it is available
        lib.optionalString (localIP != null) ''
          Match Originalhost ${name}.${localDomain}
            Hostname ${localIP}
        ''
        +
        # Use the public IP if available.
        lib.optionalString (publicIP != null) ''
          Match Originalhost ${name}.${publicDomain}
            Hostname ${publicIP}
        ''
        +
        # Use the VPN IP if available.
        lib.optionalString (vpn.enable) ''
          Match Originalhost ${name}.${vpn.domain}
            Hostname ${cfg.lib.vpn.ip}
        ''
    )
    hosts);
}
