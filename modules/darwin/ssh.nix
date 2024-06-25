{
  config,
  lib,
  nixosConfigurations,
  ...
}:
with lib; {
  # Load SSH known hosts
  programs.ssh.knownHosts =
    mapAttrs (name: machine: let
      cfg = machine.config;
      inherit (cfg.settings) sshPublicKey publicIP localIP;
    in {
      hostNames =
        [name]
        ++ optionals (publicIP != null) ["${name}.public" publicIP]
        ++ optionals (localIP != null) ["${name}.local" localIP];
      publicKey = sshPublicKey;
    })
    nixosConfigurations;

  environment.etc."ssh/ssh_config.d/300-hosts.conf".text = builtins.concatStringsSep "\n" (mapAttrsToList (
      name: machine: let
        cfg = machine.config;
        inherit (cfg.settings) publicIP localIP;
      in
        # Use the local IP if it is available
        optionalString (localIP != null) ''
          Match Originalhost ${name}.local
            Hostname ${localIP}
        ''
        +
        # Use the public IP if available.
        optionalString (publicIP != null) ''
          Match Originalhost ${name}.public
            Hostname ${publicIP}
        ''
    )
    nixosConfigurations);
}
