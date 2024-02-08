{pkgs, ...}: {
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.settings.cores = 8;
  networking.hostName = "badger";

  # TODO reconfigure
  # localIP = "10.136.1.242";
  # services.linux-builder.enable = true;
  # services.linux-builder.crossBuilding.enable = false; # Not working yet, QEMU issue. See todo list

  custom = {
    windowManager.enable = true;
    keyboard.keyMapping.enable = true;
  };

  homebrew.casks = [
    "arduino"
    "balenaetcher"
    "docker"
    "goldencheetah"
    "google-chrome" # nix package only for linux
    "grammarly-desktop"
    "grammarly"
    "notion"
    "skype-for-business"
    "skype"
    "sonos"
    "steam" # not available on nixpkgs
    "supertuxkart" # for kids
    "webex"
    "zwift"
  ];

  homebrew.masApps = {
    "HP Smart for Desktop" = 1474276998;
  };

  home-manager.users.pilou = {
    imports = [../home-manager/pilou-gui.nix];

    home.packages = with pkgs; [
      discord
      gimp
    ];

    programs.zsh.dirHashes = {
      config = "$HOME/dev/plmercereau/nix-config";
      dev = "$HOME/dev";
      gh = "$HOME/dev/plmercereau";
    };
  };
}
