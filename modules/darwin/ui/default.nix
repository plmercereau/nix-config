{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  enableWindowManager = config.custom.windowManager.enable;
in {
  options.custom.windowManager = {
    enable = mkEnableOption "the window manager";
  };

  config = mkIf enableWindowManager {
    # Show spaces in the menu bar
    homebrew.casks = ["spaceman"];

    system.defaults = {
      # Use F1, F2, etc. keys as standard function keys.
      NSGlobalDomain."com.apple.keyboard.fnState" = true;

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.2;
        orientation = "left";
        mru-spaces = false;
        show-recents = false;
        expose-animation-duration = 0.2;
        tilesize = 48;
        launchanim = false;
        static-only = false;
        showhidden = true;
        show-process-indicators = true;

        # mouse in top right corner will (1) do nothing
        # * See https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.dock.wvous-tr-corner
        wvous-tr-corner = 1;
      };
    };
  };
}
