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

  # TODO only if ui is enabled
  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    meslo-lg
    meslo-lgs-nf
  ];

  time.timeZone = "Europe/Brussels";
  settings = {
    networking.wireless.localNetworkId = "mjmp";
    networking.vpn.enable = true;
    users.users = {
      pilou = {
        enable = true;
        admin = true;
        publicKeys = cluster.adminKeys;
      };
    };
  };
  home-manager.users.pilou = import ./home-manager/pilou-minimal.nix;
}
