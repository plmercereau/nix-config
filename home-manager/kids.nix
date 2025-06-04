{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
  ];
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
    };
  };
  # TODO monitor dconf settings and add them here e.g. gnome extensions
  dconf.settings = {
    "org/gnome/desktop/lockdown" = {
      # Prevent the user from logging out
      disable-log-out = true;
    };
  };

  home.packages = with pkgs; [
    gcompris
    tuxpaint # TODO config file https://tuxpaint.org/docs/en/html/OPTIONS.html#cfg-file
    extremetuxracer
    frozen-bubble
    gedit # text editor
    tuxtype
    #   kstars # awful UI
    libsForQt5.marble
    #   libsForQt5.kturtle # a bit too early
    #   celestia # Real-time 3D simulation of space -> GTK, not nice
    #   frozen-bubble # complicated to make it work - and needs internet...
    superTux
    # superTuxKart
    hedgewars
    # freeciv # ? too early?
    lutris # game manager
    wine
    # iina # TODO vlc, as iina is not available for linux. Or: https://github.com/mpv-player/mpv/wiki/Applications-using-mpv
    openshot-qt # TODO find the simplest video editor: https://filmora.wondershare.com/video-editor/free-linux-video-editor.html
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    sushi # preview files
    gpaste # clipboard manager
    simple-scan # scanner
    gnome-chess
    spotify
  ];
}
