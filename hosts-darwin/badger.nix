{
  pkgs,
  config,
  ...
}: {
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.settings.cores = 8;

  nix.buildMachines = [
    {
      hostName = "fennec";
      supportedFeatures = ["kvm" "benchmark" "big-parallel"];
      speedFactor = 1;
      maxJobs = 8;
      sshUser = "pilou";
      sshKey = "/Users/pilou/.ssh/id_ed25519";
      protocol = "ssh-ng";
      systems = ["x86_64-linux"];
    }
  ];

  networking.hostName = "badger";

  # TODO reconfigure
  # localIP = "10.136.1.242";

  custom = {
    windowManager.enable = true;
    keyboard.keyMapping.enable = true;
    linux-builder.enable = true;
    # linux-builder.initialBuild = true;
  };

  # launchd.daemons.linux-builder = {
  #   serviceConfig.Debug = true;
  #   serviceConfig.StandardErrorPath = "/var/log/linux-builder-err.log";
  #   serviceConfig.StandardOutPath = "/var/log/linux-builder.log";
  # };

  homebrew.casks = [
    "altair-graphql-client"
    "figma"
    "cursor"
    "claude"
    "anythingllm"
    "spaceman" # Show spaces in the menu bar
    "balenaetcher"
    # "protonvpn"
    "adguard-vpn"
    # "rancher"
    # "docker" # Either use docker or rancher, but not both
    # "goldencheetah"
    "ghostty" # TODO 1.1.3 nix package is broken
    "google-chrome" # nix package only for linux
    "google-drive" # no nix package
    "grammarly-desktop"
    # "grammarly" # TODO discontinued - use MAS
    "notion"
    # "skype-for-business"
    # "skype"
    "sonos"
    # "steam" # not available on nixpkgs
    "virtualbox"
    "webex"
    "supertuxkart"
    "zwift"
    "microsoft-teams" # the "teams" nix package is not new enough
    "obsidian"
    "orbstack"
    "zed"
  ];

  homebrew.masApps = {
    # "HP Smart for Desktop" = 1474276998;
    # https://apps.apple.com/be/app/obsidian-web-clipper/id6720708363
  };

  homebrew.taps = ["stacklok/tap"];
  homebrew.brews = [
    "thv" # toolhive
  ];
  users.users.pilou.home = "/Users/pilou";
  home-manager.users.pilou = {
    imports = [
      ../home-manager/pilou-gui.nix
      # ../home-manager/wireguard.nix
    ];

    home.packages = with pkgs; [
      discord
      gimp
    ];

    programs.zsh.dirHashes = {
      config = "$HOME/dev/plmercereau/nix-config";
      dev = "$HOME/dev";
      gh = "$HOME/dev/plmercereau";
      blsq = "$HOME/dev/blsq";
      obs = "$HOME/dev/obsidian";
    };
  };
}
