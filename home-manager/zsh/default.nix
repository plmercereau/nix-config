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
    dotDir = "${config.home.homeDirectory}/.config/zsh";
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    initContent = lib.mkOrder 550 ''
      ${builtins.readFile ./p10k.zsh}
      hash go 2>/dev/null && export PATH=$PATH:$(go env GOPATH)/bin
      hash yarn 2>/dev/null && export PATH=$PATH:$HOME/.yarn/bin

      # hash direnv 2>/dev/null && eval "$(direnv hook zsh)"
      export PATH=$PATH:$HOME/.local/bin


    '';
  };
}
