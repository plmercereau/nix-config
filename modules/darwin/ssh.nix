{
  config,
  lib,
  nixosConfigurations,
  ...
}:
with lib; {
  # Load SSH known hosts
  programs.ssh.knownHosts =
    lib.mapAttrs (name: machine: let
      cfg = machine.config;
      inherit (cfg.settings) sshPublicKey publicIP localIP vpn;
    in {
      hostNames =
        lib.optionals vpn.enable [cfg.lib.vpn.ip name cfg.lib.vpn.fqdn]
        ++ lib.optional (publicIP != null) publicIP
        ++ lib.optional (localIP != null) localIP;
      publicKey = sshPublicKey;
    })
    nixosConfigurations;

  environment.etc."ssh/ssh_config.d/300-hosts.conf".text = builtins.concatStringsSep "\n" (lib.mapAttrsToList (
      name: machine: let
        cfg = machine.config;
        inherit (cfg.settings) publicIP localIP vpn;
      in
        # Use the local IP if it is available
        lib.optionalString (localIP != null) ''
          Match Originalhost ${name}.local
            Hostname ${localIP}
        ''
        +
        # Use the public IP if available.
        lib.optionalString (publicIP != null) ''
          Match Originalhost ${name}.public
            Hostname ${publicIP}
        ''
        +
        # Use the VPN IP if available.
        lib.optionalString (vpn.enable) ''
          Match Originalhost ${cfg.lib.vpn.fqdn}
            Hostname ${cfg.lib.vpn.ip}
        ''
    )
    nixosConfigurations);
}
