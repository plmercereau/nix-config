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

    services.yabai = {
      enable = true;
      package = pkgs.yabai;
      enableScriptingAddition = true;
      # https://www.josean.com/posts/yabai-setup
      config = let
        padding = 0;
      in {
        layout = "float";
        focus_follows_mouse = "autofocus";
        mouse_follows_focus = "off";
        mouse_modifier = "fn";
        mouse_action1 = "resize";
        mouse_action2 = "move";
        # New window spawns to the right if vertical split, or bottom if horizontal split
        window_placement = "second_child";
        window_opacity = "off";
        top_padding = padding;
        bottom_padding = padding;
        left_padding = padding;
        right_padding = padding;
        window_gap = 3;
      };
      # TODO remap playpause, next, previous on f7-f9: https://github.com/yorhodes/dotfiles/commit/ce74bccb45590c91435cdc321d5860e0222806e5

      # The first window of the "$1" program will be put full-screen and moved to the workspace $2
      extraConfig = ''
        # Reload sa when the dock restarts
        yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
        osascript -e 'display notification  "Yabai configuration loaded"'
      '';
    };

    # See: https://github.com/LnL7/nix-darwin/issues/333
    system.activationScripts.postActivation.text = ''
      su - "$(logname)" -c '${pkgs.skhd}/bin/skhd -r'
    '';

    services.skhd = {
      enable = true;
      skhdConfig = let
        reloadConfig = pkgs.writeShellScript "reloadConfig" ''
          rm /tmp/yabai*
          pkill yabai
          ${pkgs.skhd}/bin/skhd -r
          osascript -e 'display notification  "restart yabai and reload skhd"'
        '';
        goFullScreen = pkgs.writeShellScript "goFullScreen" ''
          alias jq=${pkgs.jq}/bin/jq
          APP_NAME=$1
          SPACE=$2
          TITLE=$3

          WINDOW=$(yabai -m query --windows | jq --arg app_name "$APP_NAME"  --arg title "$TITLE" '[.[] | select((.app == $app_name) and ((.title | startswith($title)) or (.title == "")))] | first')
          if [ "$WINDOW" == "null" ]; then
              open -a $APP_NAME
              WINDOW="null"
              while [ "$WINDOW" == "null" ]; do
                  WINDOW=$(yabai -m query --windows | jq --arg app_name "$APP_NAME" --arg title "$TITLE" '[.[] | select((.app == $app_name) and (.title | startswith($title)))] | first')
                  sleep 0.2
              done
          fi

          CURRENT_SPACE=$(jq -rn --argjson window "$WINDOW" '$window."space"')

          WINDOW_ID=$(echo $WINDOW | jq -r '.id')
          IS_FULLSCREEN=$(jq -rn --argjson window "$WINDOW" '$window."is-native-fullscreen"')
          if [ "$IS_FULLSCREEN" != "true" ]; then
              yabai -m window $WINDOW_ID --toggle native-fullscreen
              INITIAL_SPACE=$CURRENT_SPACE
              while [ "$CURRENT_SPACE" == "$INITIAL_SPACE" ]; do
                  WINDOW=$(yabai -m query --windows --window $WINDOW_ID)
                  CURRENT_SPACE=$(echo $WINDOW | jq -r '.space')
                  sleep 0.2
              done
              WINDOW_ID=$(echo $WINDOW | jq -r '.id')
          fi
          if [ "$CURRENT_SPACE" != "$SPACE" ]; then
              yabai -m space $CURRENT_SPACE --move $SPACE
          fi
          yabai -m space --focus $SPACE
        '';
      in ''
        fn - r: ${reloadConfig}

        ### ARRANGE WINDOWS ###
        # rotate layout clockwise
        alt + cmd - r : yabai -m space --rotate 270

        # flip along y-axis
        alt + cmd - y : yabai -m space --mirror y-axis

        # flip along x-axis
        alt + cmd - x : yabai -m space --mirror x-axis

        # maximize a window
        alt + cmd - m : yabai -m window --toggle windowed-fullscreen

        ### CHANGE FOCUS ###
        # change focus between spaces
        f1 : ${goFullScreen} ChatGPT 1
        f2 : ${goFullScreen} Ghostty 2
        f3 : ${goFullScreen} Safari 3 Personal
        f4 : yabai -m space --focus 4
        f5 : yabai -m space --focus 5
        f6 : yabai -m space --focus 6
        f7 : yabai -m space --focus 7
        f8 : yabai -m space --focus 8
        f9 : yabai -m space --focus 9

        # move window to space #
        # cmd - f1 : yabai -m window --space 1;
        cmd - f2 : yabai -m window --space 2;
        # cmd - f3 : yabai -m window --space 3;
        # cmd - f4 : yabai -m window --space 4;
        cmd - f5 : yabai -m window --space 5;
        cmd - f6 : yabai -m window --space 6;
        cmd - f7 : yabai -m window --space 7;
        cmd - f8 : yabai -m window --space 8;
        cmd - f8 : yabai -m window --space 9;

        # move window to space and follow focus
        # alt + cmd - f1 : yabai -m window --space 1; yabai -m space --focus 1
        alt + cmd - f2 : yabai -m window --space 2; yabai -m space --focus 2
        # alt + cmd - f3 : yabai -m window --space 3; yabai -m space --focus 3
        # alt + cmd - f4 : yabai -m window --space 4; yabai -m space --focus 4
        alt + cmd - f5 : yabai -m window --space 5; yabai -m space --focus 5
        alt + cmd - f6 : yabai -m window --space 6; yabai -m space --focus 6
        alt + cmd - f7 : yabai -m window --space 7; yabai -m space --focus 7
        alt + cmd - f8 : yabai -m window --space 8; yabai -m space --focus 8
        alt + cmd - f9 : yabai -m window --space 9; yabai -m space --focus 9
      '';
    };
  };
}
