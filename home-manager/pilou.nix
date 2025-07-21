{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./pilou-minimal.nix
  ];
  home.packages = with pkgs; [
    gemini-cli
    uv # needed for MCPs
  ];
}
