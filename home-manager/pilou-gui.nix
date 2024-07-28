{
  lib,
  pkgs,
  ...
}: let
  isLinux = pkgs.hostPlatform.isLinux;
  isDarwin = pkgs.hostPlatform.isDarwin;
in {
  imports = [
    ./pilou.nix
    ./alacritty.nix
    ./editors/vscode.nix
  ];

  programs.helix.defaultEditor = lib.mkForce false;

  home.packages = with pkgs;
    [
      spotify
      zoom-us
      # dbeaver-bin # TODO not supported on darwin (anymore)
      qbittorrent
    ]
    ++ lib.optionals isLinux [
      google-chrome
    ]
    ++ lib.optionals isDarwin [
      utm
      iina
      teams # not working on Linux
    ]
    ++ [
      # Bluesquare tools
      slack
      _1password-gui
    ];

  # Works both with Gnome and MacOS
  programs.zsh.dirHashes = {
    desk = "$HOME/Desktop";
    dl = "$HOME/Downloads";
    docs = "$HOME/Documents";
    vids = "$HOME/Videos";
  };
}
