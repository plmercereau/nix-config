# Settings common to all the machines
{
  cluster,
  config,
  lib,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  programs.zsh.enable = true;
  # * Required for zsh completion, see: https://nix-community.github.io/home-manager/options.html#opt-programs.zsh.enableCompletion
  environment.pathsToLink = ["/share/zsh"];

  # TODO only if ui is enabled
  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    meslo-lg
    meslo-lgs-nf
  ];

  time.timeZone = "Europe/Brussels";
  settings = {
    networking.vpn.enable = true;
    users.users = {
      pilou = {
        enable = true;
        isAdmin = true;
        publicKeys = cluster.adminKeys;
      };
    };
  };
  home-manager.users.pilou = import ./home-manager/pilou-minimal.nix;
  # pilou is a member of the kubernetes admin group, if kubernetes is enabled
  users.users.pilou.extraGroups = lib.optional config.settings.services.kubernetes.enable config.settings.services.kubernetes.group;
}
