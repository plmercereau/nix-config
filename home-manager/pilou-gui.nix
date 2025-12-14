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
    # ./editors/vscode.nix
    ./editors/zed.nix
  ];

  programs.helix.defaultEditor = lib.mkForce false;

  home.packages = with pkgs;
    [
      nodejs
      uv
      ghostty-bin
      zoom-us
      slack
      # dbeaver-bin # TODO not supported on darwin (anymore)
      # qbittorrent # TODO crashes
    ]
    ++ lib.optionals isLinux [
      google-chrome
    ]
    ++ lib.optionals isDarwin [
      utm
      iina
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
