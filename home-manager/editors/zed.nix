{
  pkgs,
  lib,
  config,
  ...
}: let
  extensions = config.programs.vscode.profiles.default.extensions;
in {
  programs.git.settings = {
    core.editor = "zed --wait";
  };

  home.sessionVariables = {
    EDITOR = lib.mkForce "zed --wait";
  };

  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor;
  };
}
