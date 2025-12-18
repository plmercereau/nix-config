{hardware, ...}: {
  nixpkgs.hostPlatform = "x86_64-darwin";

  # TODO reconfigure
  # localIP = "10.136.1.99";
  # services.nix-builder.enable = true;
  # services.linux-builder.enable = true;

  custom = {
    windowManager.enable = true;
    keyboard.keyMapping.enable = true;
  };

  homebrew.casks = [
    "balenaetcher"
    # "docker"
    "orbstack"
    "google-chrome" # nix package only for linux
    "zed"
    "grammarly-desktop"
    "grammarly"
    "notion"
    "skype-for-business"
    "skype"
    "sonos"
    "webex"
    "zwift"
  ];

  users.users.pilou.home = "/Users/pilou";
  home-manager.users.pilou = {
    imports = [../home-manager/pilou-gui.nix];

    programs.zsh.dirHashes = {
      config = "$HOME/dev/plmercereau/nix-config";
      dev = "$HOME/dev";
      gh = "$HOME/dev/plmercereau";
    };
  };
}
