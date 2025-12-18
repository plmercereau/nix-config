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

  # Use brew instead so we don't need to compile zed
  # programs.zed-editor = lib.mkIf (!isDarwin) {
  #   enable = true;
  #   package = pkgs.zed-editor;
  # };
}
