{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (pkgs) stdenv;
  isDarwin = stdenv.isDarwin;
in {
  # ? load only if the user is using zsh?
  home.file.".zshrc".text = ''
  '';

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    initExtraBeforeCompInit = let
      p10k = builtins.readFile ./p10k.zsh;
    in ''
      ${p10k}

      hash go 2>/dev/null && export PATH=$PATH:$(go env GOPATH)/bin
      hash yarn 2>/dev/null && export PATH=$PATH:$HOME/.yarn/bin

      # hash direnv 2>/dev/null && eval "$(direnv hook zsh)"
      export PATH=$PATH:$HOME/.local/bin

      # TODO get rid of this as soon as the ghostty nix package works
      ${lib.optionalString isDarwin ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      ''}
    '';
  };
}
