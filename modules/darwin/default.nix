{
  lib,
  pkgs,
  config,
  options,
  nixosConfigurations,
  ...
}:
with lib; let
  inherit (config.networking) hostName;
  builders =
    filterAttrs
    (_: machine: machine.config.settings.services.nix-builder.enable && machine.config.networking.hostName != hostName)
    nixosConfigurations;
  nbBuilers = builtins.length (builtins.attrNames builders);
in {
  imports = [
    ./keyboard.nix
    ./linux-builder.nix
    ./packages.nix
    ./ssh.nix
    ./system.nix
    ./ui
  ];

  # "fonts" renamed to "packages" in nixos, but not in nix-darwin
  options.fonts.packages = options.fonts.fonts;

  config = {
    time.timeZone = "Europe/Brussels";

    nixpkgs.config.allowUnfree = true;
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };

    programs.zsh.enable = true;
    # * Required for zsh completion, see: https://nix-community.github.io/home-manager/options.html#opt-programs.zsh.enableCompletion
    environment.pathsToLink = ["/share/zsh"];

    fonts.fontDir.enable = true;
    fonts.packages = with pkgs; [
      meslo-lg
      meslo-lgs-nf
    ];

    # Enable sudo authentication with Touch ID
    # See: https://daiderd.com/nix-darwin/manual/index.html#opt-security.pam.enableSudoTouchIdAuth
    security.pam.enableSudoTouchIdAuth = true;

    # * See: https://github.com/LnL7/nix-darwin/blob/master/tests/system-defaults-write.nix
    system.defaults.loginwindow.GuestEnabled = false;
    # Apply settings on activation.
    # * See https://medium.com/@zmre/nix-darwin-quick-tip-activate-your-preferences-f69942a93236
    system.activationScripts.postUserActivation.text = ''
      # Following line should allow us to avoid a logout/login cycle
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      killall Dock
      osascript -e 'display notification "Nix settings applied"'
    '';

    services.nix-daemon.enable = true; # Make sure the nix daemon always runs
    nix = {
      package = pkgs.nixVersions.stable;
      configureBuildUsers = true; # Creates "build users"
      settings = {
        max-jobs = lib.mkDefault config.nix.settings.cores; # use all cores
        # TODO not ideal difference bw admin and wheel. And also, not ideal to reuse as nix trusted users. Create a separate group?
        trusted-users = ["@admin"];
        trusted-public-keys = ["devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="];
        trusted-substituters = ["https://devenv.cachix.org"];
        extra-experimental-features = ["nix-command" "flakes"];
        keep-outputs = true;
        keep-derivations = true;
        # ! Remove when this issue will be solved: https://github.com/NixOS/nix/issues/7273
        auto-optimise-store = mkForce false;
      };
      # https://nixos.wiki/wiki/Distributed_build
      distributedBuilds = true;
      # optional, useful when the builder has a faster internet connection than yours
      extraOptions = ''
        builders-use-substitutes = true
      '';
    };

    # Load SSH known hosts
    programs.ssh.knownHosts =
      lib.mapAttrs (name: machine: let
        cfg = machine.config;
        inherit (cfg.settings) sshPublicKey;
        inherit (cfg.settings.networking) publicIP localIP;
      in {
        hostNames =
          lib.optionals cfg.settings.networking.vpn.enable [cfg.lib.vpn.ip cfg.networking.hostName "${cfg.networking.hostName}.${cfg.settings.networking.vpn.domain}"]
          ++ lib.optional (publicIP != null) publicIP
          ++ lib.optional (localIP != null) localIP;
        publicKey = sshPublicKey;
      })
      nixosConfigurations;

    environment.etc."ssh/ssh_config.d/300-hosts.conf" = {
      text = builtins.concatStringsSep "\n" (lib.mapAttrsToList (
          name: machine: let
            inherit (machine.config.settings.networking) publicIP publicDomain localIP localDomain;
          in
            # Use the local IP if it is available
            lib.optionalString (localIP != null) ''
              Match Originalhost ${name}.${localDomain}
                Hostname ${localIP}
            ''
            +
            # Use the public IP if available. T
            lib.optionalString (publicIP != null) ''
              Match Originalhost ${name}.${publicDomain}
                Hostname ${publicIP}
            ''
        )
        nixosConfigurations);
    };
  };
}
