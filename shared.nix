# Settings common to all the machines
{
  cluster,
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
}
