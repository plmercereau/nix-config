{
  config,
  hardware,
  pkgs,
  lib,
  ...
}: let
  common = "common";
  media = false;
in {
  imports = [hardware.nuc ../modules/nixos];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  fonts.packages = with pkgs; [
    corefonts # Microsoft fonts, required by some games
  ];

  # Supertuxkart
  # networking.firewall.allowedTCPPorts = [2757 2759];
  networking.firewall.allowedTCPPorts = [2757 2759 64172];
  # networking.firewall.allowedUDPPorts = [2757 2759 ];
  networking.firewall.allowedUDPPorts = [2757 2759 67 69 4011];

  virtualisation.docker.enable = true;
  # users.users.pilou.extraGroups = ["docker"];

  settings = {
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIM5l9qxM+KFhsxJR1ZM0QYu/s5VHJQAARnuSDi4iIkP";
    localIP = "10.136.1.11";

    # nix-builder.enable = true;

    kubernetes = {
      enable = false;
      # labels.test = "enabled";
    };

    # prometheus.federation.upstream.enable = true;
    local-server.enable = true;
    # fleet-manager.enable = true;
    # TODO disabled?
    # rancher.enable = false;
  };

  # services.pixiecore.enable = true;
  # services.pixiecore.openFirewall = true;
  # # services.pixiecore.mode = "quick";
  # # services.pixiecore.quick = "ubuntu";
  # services.pixiecore.dhcpNoBind = true;
  # services.pixiecore.kernel = "https://boot.netboot.xyz";

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.settings = {};
  services.xserver.desktopManager.gnome.enable = true;

  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    atomix # puzzle game
    cheese # webcam tool
    epiphany # web browser
    evince # document viewer
    geary # email reader
    gnome-bluetooth
    gnome-calendar
    gnome-characters
    gnome-contacts
    gnome-logs
    gnome-music
    gnome-nettool
    gnome-power-manager
    gnome-shell
    gnome-terminal
    hitori # sudoku game
    iagno # go game
    simple-scan
    tali # poker game
    totem # video player
  ];

  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    hplipWithPlugin
    dhcping
  ];

  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  # Disable the network manager for the wifi interface
  networking.networkmanager.unmanaged = ["wlo1"];

  # conflicts on port 80 (k3s enables traefik)
  services.nginx.enable = !config.settings.kubernetes.enable;

  services.transmission.enable = media;
  services.transmission.group = common;
  services.jellyfin.enable = media;
  services.jellyfin.group = common;

  services.radarr.enable = media;
  services.radarr.group = common;
  services.sonarr.enable = media;
  services.sonarr.group = common;
  services.prowlarr.enable = media;
  services.bazarr.group = common;
  services.bazarr.enable = media;

  # TODO...
  networking.enableIPv6 = false;
  /*
  Common OneDrive configuration.
  ! OneDrive must be authenticated first !
  sudo -u common onedrive
  */
  users.users.${common} = {
    isSystemUser = true;
    group = common;
    homeMode = "770";
    createHome = true;
    home = "/var/lib/${common}";
    linger = true; # Start systemd services on boot rather than on first login
    # * the following is not necessary, but can be convenient for debugging
    shell = pkgs.zsh;
    extraGroups = ["systemd-journal"];
    openssh.authorizedKeys.keys = config.lib.ext_lib.adminKeys;
  };
  users.groups.${common} = {};

  home-manager.users.${common} = {lib, ...}: {
    home.stateVersion = "24.05";
    # ? remote "online" mount: onedriver: https://github.com/jordanisaacs/dotfiles/blob/42c02301984a1e2c4da6f3a88914545feda00360/modules/users/office365/default.nix#L52

    home.packages = [pkgs.onedrive];
    home.file.".config/onedrive/config".text = ''
      sync_dir = "~"
      skip_file = "~*|.~*|*.tmp"
      log_dir = "/var/log/onedrive/"
      skip_symlinks = "false"
      skip_dotfiles = "true"
      sync_dir_permissions = "770"
      sync_file_permissions = "660"
    '';

    systemd.user.services.onedrive = {
      Unit.Description = "Onedrive Synchronisation service";
      Install.WantedBy = ["default.target"];
      Service = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.onedrive}/bin/onedrive --monitor --confdir=%h/.config/onedrive
        '';
        Restart = "on-failure";
        RestartSec = 3;
        RestartPreventExitStatus = 3;
      };
    };
  };

  # !!!!!!!!!! SAMBA !!!!!!!!
  services.samba = {
    enable = true;

    shares = {
      common = {
        path = "/var/lib/${common}";
        comment = "Common files";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0660";
        "directory mask" = "0770";
        "force user" = common;
        "force group" = common;
      };
      scanner = {
        path = "/var/lib/scanner";
        comment = "Scanner";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0660";
        "directory mask" = "0770";
        "force user" = "scanner";
        "force group" = common;
      };
    };
  };

  # !!!!!!!!!!!! Scanner / Printer !!!!!!!!!!!!!!
  # * See: https://nixos.wiki/wiki/Printing
  # * See: https://developers.hp.com/hp-linux-imaging-and-printing/install/step4/cups/net
  services.printing.enable = true;
  services.printing.drivers = [pkgs.hplipWithPlugin];
  hardware.printers = {
    ensurePrinters = [
      {
        name = "printer";
        location = "home";
        # TODO configure through tailscale
        deviceUri = "hp:/net/HP_OfficeJet_Pro_9020_series?ip=10.136.1.44";
        model = "drv:///hp/hpcups.drv/hp-officejet_pro_9020_series.ppd";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "printer";
  };

  # ! add the user to samba: sudo smbpasswd -a scanner
  users.users.scanner = {
    isSystemUser = true;
    group = common;
    homeMode = "770";
    createHome = true;
    home = "/var/lib/scanner";
  };

  # home-manager.users.gdm = {
  #   home.stateVersion = "23.05";
  #   home.file.".config/monitors.xml".text = ''
  #     <monitors version="2">
  #       <configuration>
  #         <logicalmonitor>
  #           <x>0</x>
  #           <y>0</y>
  #           <scale>2</scale>
  #           <primary>yes</primary>
  #           <monitor>
  #             <monitorspec>
  #               <connector>DP-3</connector>
  #               <vendor>HPN</vendor>
  #               <product>HP Z27</product>
  #               <serial>CN4913011H</serial>
  #             </monitorspec>
  #             <mode>
  #               <width>3840</width>
  #               <height>2160</height>
  #               <rate>59.997</rate>
  #             </mode>
  #           </monitor>
  #         </logicalmonitor>
  #       </configuration>
  #     </monitors>
  #   '';
  # };

  # TODO configure
  # services.malcontent.enable = true;

  # * User: pilou
  home-manager.users.pilou = import ../home-manager/pilou.nix;
  users.users.pilou.extraGroups = [common "docker"];

  # * User: kids
  settings.users.users.kids.enable = true;
  home-manager.users.kids = import ../home-manager/kids.nix;
  # The pilou user can access to the kids user with his ssh keys
  users.users.kids.openssh.authorizedKeys.keys = config.users.users.pilou.openssh.authorizedKeys.keys;

  # * Autologin
  # services.xserver.displayManager.autoLogin.enable = true;
  # services.xserver.displayManager.autoLogin.user = "kids";
  # systemd.services."getty@tty1".enable = false;
  # systemd.services."autovt@tty1".enable = false;
}
