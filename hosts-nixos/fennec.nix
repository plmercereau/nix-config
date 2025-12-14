{
  config,
  pkgs,
  lib,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  environment.pathsToLink = ["/share/zsh"];
  time.timeZone = "Europe/Brussels";

  networking = {
    firewall = {
      allowedTCPPorts = [2757 2759 64172];
      allowedUDPPorts = [2757 2759 67 69 4011];
    };
  };

  # * User: pilou
  users.users.pilou.extraGroups = ["data"];
  users.users.data = {
    isSystemUser = true;
    group = "data";
    homeMode = "770";
    createHome = true;
    home = "/data";
    linger = true; # Start systemd services on boot rather than on first login
    # * the following is not necessary, but can be convenient for debugging
    shell = pkgs.zsh;
    extraGroups = ["systemd-journal"];
    openssh.authorizedKeys.keys = config.lib.ext_lib.adminKeys;
  };
  users.groups.data = {};

  # TODO pilou's user + public keys -> in home-manager???
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.pilou = import ../home-manager/pilou.nix;
  };

  programs.zsh.enable = true;
  # * Required for zsh completion, see: https://nix-community.github.io/home-manager/options.html#opt-programs.zsh.enableCompletion

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    autoPrune.enable = true;
  };

  virtualisation.oci-containers.containers = {
    test = {
      image = "library/hello-world";
      volumes = [];
      ports = [
        # ip:hostport:containerport
        "127.0.0.1:8080:8080"
      ];
    };
  };

  # TODO use default nix options
  settings = {
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIM5l9qxM+KFhsxJR1ZM0QYu/s5VHJQAARnuSDi4iIkP";
    localIP = "10.136.1.11";
  };

  # Enable avahi mdns
  services.avahi = {
    enable = true;
    domainName = "home";
  };

  # conflicts on port 80 (k3s enables traefik)
  services.nginx = {
    enable = true;
    virtualHosts.${config.networking.hostName}.locations = {
      "/hello" = {
        proxyPass = "http://127.0.0.1:8080";
        recommendedProxySettings = true;
      };
    };
  };

  services.transmission = {
    enable = true;
    group = "data";
  };
  services.jellyfin = {
    enable = true;
    group = "data";
  };

  services.radarr = {
    enable = true;
    group = "data";
  };
  services.sonarr = {
    enable = true;
    group = "data";
  };
  services.prowlarr = {
    enable = true;
    group = "data";
  };
  services.bazarr = {
    enable = true;
    group = "data";
  };

  # home-manager.users.data = {lib, ...}: {
  #   home.stateVersion = "24.05";
  #   # ? remote "online" mount: onedriver: https://github.com/jordanisaacs/dotfiles/blob/42c02301984a1e2c4da6f3a88914545feda00360/modules/users/office365/default.nix#L52

  #   home.packages = [pkgs.onedrive];
  #   home.file.".config/onedrive/config".text = ''
  #     sync_dir = "~"
  #     skip_file = "~*|.~*|*.tmp"
  #     log_dir = "/var/log/onedrive/"
  #     skip_symlinks = "false"
  #     skip_dotfiles = "true"
  #     sync_dir_permissions = "770"
  #     sync_file_permissions = "660"
  #   '';

  #   systemd.user.services.onedrive = {
  #     Unit.Description = "Onedrive Synchronisation service";
  #     Install.WantedBy = ["default.target"];
  #     Service = {
  #       Type = "simple";
  #       ExecStart = ''
  #         ${pkgs.onedrive}/bin/onedrive --monitor --confdir=%h/.config/onedrive
  #       '';
  #       Restart = "on-failure";
  #       RestartSec = 3;
  #       RestartPreventExitStatus = 3;
  #     };
  #   };
  # };

  # !!!!!!!!!! SAMBA !!!!!!!!
  services.samba = {
    enable = true;
    shares = {
      "data" = {
        path = "/data/shared";
        comment = "data files";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0660";
        "directory mask" = "0770";
        "force user" = "data";
        "force group" = "data";
      };
    };
  };
}
