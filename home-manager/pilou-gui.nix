{
  lib,
  pkgs,
  config,
  ...
}: let
  isLinux = pkgs.hostPlatform.isLinux;
  isDarwin = pkgs.hostPlatform.isDarwin;
in {
  imports = [
    ./pilou.nix
    # ./alacritty.nix
    ./editors/vscode.nix
  ];

  programs.helix.defaultEditor = lib.mkForce false;

  home.packages = with pkgs;
    [
      # ghostty # TODO still broken (1.1.3)
      spotify
      zoom-us
      # dbeaver-bin # TODO not supported on darwin (anymore)
      qbittorrent
      # Zed editor
      # zed-editor # TODO deactivated and using brew instead: this package needs full compilation
    ]
    ++ lib.optionals isLinux [
      google-chrome
    ]
    ++ lib.optionals isDarwin [
      utm
      iina
    ]
    ++ [
      # Bluesquare tools
      slack
      # _1password-gui # TODO broken
      (pkgs.rstudioWrapper.override {
        packages = with pkgs.rPackages; [
          ggplot2
          dplyr
          xts
        ];
      })
    ];

  home.sessionVariables = {
    # Needed for Ghostty to work when using ssh
    # * See: https://github.com/ghostty-org/ghostty/issues/3335
    TERM = "xterm-256color";
  };

  # Works both with Gnome and MacOS
  programs.zsh.dirHashes = {
    desk = "$HOME/Desktop";
    dl = "$HOME/Downloads";
    docs = "$HOME/Documents";
    vids = "$HOME/Videos";
  };
}
