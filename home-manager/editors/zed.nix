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

  # On macOS, `pkgs.zed-editor` is frequently not available from binary caches
  # (especially on aarch64-darwin), which forces a costly source build.
  #
  # Instead, install Zed as a Homebrew cask (see darwin host config) and expose
  # a stable `zed` CLI on $PATH for `EDITOR=zed --wait`.
  home.packages = lib.optionals isDarwin [
    (pkgs.writeShellScriptBin "zed" ''
      if [ -x /Applications/Zed.app/Contents/MacOS/zed ]; then
        exec /Applications/Zed.app/Contents/MacOS/zed "$@"
      fi

      echo "Zed.app not found at /Applications/Zed.app." >&2
      echo "Install it with Homebrew: brew install --cask zed" >&2
      exit 127
    '')
  ];

  # Use brew instead so we don't need to compile zed
  # programs.zed-editor = lib.mkIf (!isDarwin) {
  #   enable = true;
  #   package = pkgs.zed-editor;
  # };
}
