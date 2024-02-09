{
  pkgs,
  config,
  ...
}: {
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.settings.cores = 8;
  networking.hostName = "badger";

  # TODO reconfigure
  # localIP = "10.136.1.242";

  custom = {
    windowManager.enable = true;
    keyboard.keyMapping.enable = true;
    linux-builder.enable = true;
  };

  age.secrets.vpn.file = ./badger.vpn.age;

  networking.wg-quick.interfaces.wg0 = {
    privateKeyFile = config.age.secrets.vpn.path;
    address = ["10.100.0.0/24"];
    peers = [
      {
        publicKey = "Juozjo5Mi2zPm0fwhHlo3b5956HtZOw0MxdYWOjA2XU=";
        allowedIPs = ["10.100.0.0/24"];
        endpoint = " 128.140.39.64:51820";
        persistentKeepalive = 25;
      }
    ];
    postUp = ''
      # Add the route to the VPN network
      mkdir -p /etc/resolver
      cat << EOF > /etc/resolver/vpn
      port 53
      domain vpn
      search vpn
      nameserver 10.100.0.1
      EOF
    '';

    postDown = ''
      rm -f /etc/resolver/vpn
    '';
  };

  homebrew.casks = [
    "arduino"
    "balenaetcher"
    "docker"
    "goldencheetah"
    "google-chrome" # nix package only for linux
    "grammarly-desktop"
    "grammarly"
    "notion"
    "skype-for-business"
    "skype"
    "sonos"
    "steam" # not available on nixpkgs
    "supertuxkart" # for kids
    "webex"
    "zwift"
  ];

  homebrew.masApps = {
    "HP Smart for Desktop" = 1474276998;
  };

  users.users.pilou.home = "/Users/pilou";
  home-manager.users.pilou = {
    imports = [../home-manager/pilou-gui.nix];

    home.packages = with pkgs; [
      discord
      gimp
    ];

    programs.zsh.dirHashes = {
      config = "$HOME/dev/plmercereau/nix-config";
      dev = "$HOME/dev";
      gh = "$HOME/dev/plmercereau";
    };
  };
}
