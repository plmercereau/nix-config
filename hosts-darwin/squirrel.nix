{...}: {
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.settings.cores = 8;

  # TODO reconfigure
  # localIP = "10.136.1.133";

  homebrew.casks = [
    "google-chrome" # nix package only for linux
    "skype"
    "sonos"
    "webex"
  ];

  home-manager.users.madhu = import ../home-manager/madhu.nix;
}
