{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./pilou-minimal.nix
  ];

  home.packages = with pkgs; [
    # asciinema # Recording + sharing terminal sessions
    # navi # Interactive cheat sheet
    # bitwarden-cli # not working in latest nixpkgs
    cocogitto
    ctop # container metrics & monitoring
    fdupes # Duplicate file finder
    lazydocker # Full Docker management app
    nmap
    nnn # file browser
    rclone
    tldr # complement to man
    w3m # text-based web browser
    tcpdump
    pandoc # document converter e.g. markdown to pdf
    devenv
    kubernetes-helm
  ];

  # * See: https://mipmip.github.io/home-manager-option-search/?query=programs.gh
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
