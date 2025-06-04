{
  lib,
  pkgs,
  config,
  options,
  ...
}:
with lib; let
  inherit (config.networking) hostName;
in {
  imports = [
    ./keyboard.nix
    ./linux-builder.nix
    ./packages.nix
    ./ssh.nix
    ./system.nix
    ./ui
  ];

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

    # Enable sudo authentication with Touch ID
    security.pam.services.sudo_local.touchIdAuth = true;

    # * See: https://github.com/LnL7/nix-darwin/blob/master/tests/system-defaults-write.nix
    system.defaults.loginwindow.GuestEnabled = false;
    # Apply settings on activation.
    # * See https://medium.com/@zmre/nix-darwin-quick-tip-activate-your-preferences-f69942a93236
    # TODO system.activationScripts.postUserActivation has been removed!
    # system.activationScripts.postUserActivation.text = ''
    #   # Following line should allow us to avoid a logout/login cycle
    #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    #   killall Dock
    #   # osascript -e 'display notification "Nix settings applied"'
    # '';

    nix = {
      enable = true;
      package = pkgs.nixVersions.stable;
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
  };
}
