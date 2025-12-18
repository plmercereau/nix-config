{
  config,
  pkgs,
  lib,
  ...
}: {
  disko.devices = {
    disk = {
      main = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh.enable = true;

  nixpkgs.config.allowUnfree = true;
  environment.pathsToLink = ["/share/zsh"];
  time.timeZone = "Europe/Brussels";
  system.stateVersion = "26.05";

  networking = {
    hostName = "fennec";
    firewall = {
      allowedTCPPorts = [2757 2759 64172];
      allowedUDPPorts = [2757 2759 67 69 4011];
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyxrQiE8bx1R9SG4fuNebXP8oq1duReM7E7W2M0i0fsC3PrKwQ6c9R4qzNQLREeWwtCWV0KEl0K+iriiIPa7D5psEASJapGyi5NtqEqZbM+a8BGQNdy82zEU4xU6IA4GyjxqPb/0zRiEh//4RuePZGNItW2Gl+1ZvOA1UTsHZKpGgZxWewoGdtm6EwscTy+5A4uanFWmxtpajy5J1GVR038quQLszSsTfTRr0gA80+uQbahHlGmP9HlyXrjaeKtSz9XTT95XmC/rVJkIKBYEIEf2fyV+O3hB1cxh+fb/lHFqoIJrES1qU4TAzs58Ioj0Jd3xlPGa96VJewrNXKbFjP pilou@MBPZ35"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjOA4ZYa5EY5wDvCa1I7cEnqnxdNXsmaO0+9zP1adJVtzUO98LfWqmj+MsAGr57TAgzZkxaOWJWaN48Sv7CFzCzsSl+uSoUEwsPmQWa6qiSF/4EunN3qtMZpkT+/I3kmck093gUsw+ZUfaEEoF9m7sHYCThxIOZ4BT8vr58ekSy5qgG536SgHaXQI1yX7EWQebIWxM1wEK4UQQut7tMmGt2/XmfpKkVNK5sSadn6OyneBLoJnNwHEi0FW6+jmQnvaUY0jYtCqIsmeCfG2M5T030Tt+Go5cCk5UaeGlla7MFcT6HPL8BT3tKmf9h8oR4wZqVXbuMEmvgq2FbC0B02oX plmercereau@github.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGd6o/NuO04nLqahrci03Itd/1yoK76ZpzKGgpwAEctb pilou@MBP-Pilou"
  ];

  # * User: pilou
  users.users.pilou = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ["wheel" "data"];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyxrQiE8bx1R9SG4fuNebXP8oq1duReM7E7W2M0i0fsC3PrKwQ6c9R4qzNQLREeWwtCWV0KEl0K+iriiIPa7D5psEASJapGyi5NtqEqZbM+a8BGQNdy82zEU4xU6IA4GyjxqPb/0zRiEh//4RuePZGNItW2Gl+1ZvOA1UTsHZKpGgZxWewoGdtm6EwscTy+5A4uanFWmxtpajy5J1GVR038quQLszSsTfTRr0gA80+uQbahHlGmP9HlyXrjaeKtSz9XTT95XmC/rVJkIKBYEIEf2fyV+O3hB1cxh+fb/lHFqoIJrES1qU4TAzs58Ioj0Jd3xlPGa96VJewrNXKbFjP pilou@MBPZ35"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjOA4ZYa5EY5wDvCa1I7cEnqnxdNXsmaO0+9zP1adJVtzUO98LfWqmj+MsAGr57TAgzZkxaOWJWaN48Sv7CFzCzsSl+uSoUEwsPmQWa6qiSF/4EunN3qtMZpkT+/I3kmck093gUsw+ZUfaEEoF9m7sHYCThxIOZ4BT8vr58ekSy5qgG536SgHaXQI1yX7EWQebIWxM1wEK4UQQut7tMmGt2/XmfpKkVNK5sSadn6OyneBLoJnNwHEi0FW6+jmQnvaUY0jYtCqIsmeCfG2M5T030Tt+Go5cCk5UaeGlla7MFcT6HPL8BT3tKmf9h8oR4wZqVXbuMEmvgq2FbC0B02oX plmercereau@github.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGd6o/NuO04nLqahrci03Itd/1yoK76ZpzKGgpwAEctb pilou@MBP-Pilou"
    ];
  };

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
    # openssh.authorizedKeys.keys = config.lib.ext_lib.adminKeys;
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
    # test = {
    #   image = "library/hello-world";
    #   volumes = [];
    #   ports = [
    #     # ip:hostport:containerport
    #     "127.0.0.1:8080:8080"
    #   ];
    # };
  };

  # Enable avahi mdns
  services.avahi = {
    enable = true;
    domainName = "local";
    # Ensure mDNS works out of the box (UDP/5353) and the host publishes A/AAAA
    # records so `fennec.local` resolves quickly from macOS (`dns-sd`, `ssh`, …).
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      domain = true;
    };
  };

  # conflicts on port 80 (k3s enables traefik)
  services.nginx = {
    # virtualHosts.${config.networking.hostName}.locations = {
    #   "/hello" = {
    #     proxyPass = "http://127.0.0.1:8080";
    #     recommendedProxySettings = true;
    #   };
    # };
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
    settings = {
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
