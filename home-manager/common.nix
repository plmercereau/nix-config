{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./editors/helix.nix
    ./zsh
  ];

  home.stateVersion = lib.mkDefault "24.05";

  home.packages = with pkgs; [
    eza
  ];

  home.shellAliases = {
    l = "eza -la --git";
    la = "eza -a --git";
    ls = "eza";
    ll = "eza -l --git";
    lla = "eza -la --git";
  };

  # better wget
  programs.aria2 = {
    enable = true;
  };

  programs.atuin.enable = true;
  # Sync, search and backup shell history
  # * Needs manual setup: atuin login + atuin sync. See: https://atuin.sh/docs
  # TODO automate this with an agenix secret
  # * See: https://haseebmajid.dev/posts/2023-08-12-how-sync-your-shell-history-with-atuin-in-nix/
  # create a nix home-manager activation script that runs atuin sync
  # key_path = ~/.local/share/atuin/key
  # login with for the "pilou" user with a key stored in an agenix secret

  programs.bat = {
    enable = true;
    config.theme = "gruvbox-dark";
  };

  programs.dircolors.enable = true;

  programs.direnv = {
    # Direnv, load and unload environment variables depending on the current directory.
    # https://direnv.net
    # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable

    enable = true;

    nix-direnv.enable = true;

    config.global = {
      # devenv can be slow to load, we don't need a warning every time
      warn_timeout = "3m";
      # hide unnecessary output from direnv
      hide_env_diff = true;
    };
  };

  programs.git = {
    enable = true;

    lfs.enable = true;
    extraConfig = {
      core.pager = ""; # do not use pager so git diff exits without a need to press "q
      # user.signingKey = "DA5D9235BD5BD4BD6F4C2EA868066BFF4EA525F1";
      # commit.gpgSign = true;
      init.defaultBranch = "main";
      alias.root = "rev-parse --show-toplevel";
    };

    ignores = [
      "*~"
      ".DS_Store"
      ".direnv"
      "/direnv"
      "/direnv.test"
      ".AppleDouble"
      ".LSOverride"
      "Icon"
      "._*"
      ".DocumentRevisions-V100"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".VolumeIcon.icns"
      ".com.apple.timemachine.donotpresent"
      ".AppleDB"
      ".AppleDesktop"
      "Network Trash Folder"
      "Temporary Items"
      ".apdisk"
    ];
  };
}
