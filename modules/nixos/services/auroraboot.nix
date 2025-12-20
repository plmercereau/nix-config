{
  config,
  modulesPath,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.auroraboot;
  dnsmasq = config.services.dnsmasq;
  macvlanNetworkName = "${config.networking.hostName}-auroraboot-macvlan";
in {
  options = {
    services.auroraboot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      containerImage = lib.mkOption {
        type = lib.types.str;
        default = "quay.io/kairos/hadron:v0.0.1-beta2-standard-amd64-generic-v3.6.1-beta2-k0s-v1.34.2-k0s.0";
        description = "Image to use for the Auroraboot container.";
      };

      listenPort = lib.mkOption {
        type = lib.types.int;
        default = 8080;
        description = "TCP port to listen on for the Auroraboot web interface.";
      };

      netbootListenPort = lib.mkOption {
        type = lib.types.int;
        default = 8090;
        description = "TCP port to listen on for the Netboot HTTP server.";
      };

      macvlan = {
        subnet = lib.mkOption {
          type = lib.types.str;
          default = "192.168.1.0/24";
          description = "IPv4 subnet for the macvlan network (CIDR).";
        };

        ip = lib.mkOption {
          type = lib.types.str;
          default = "192.168.1.3";
          description = "Static IPv4 to assign to the auroraboot container on the macvlan network.";
        };
      };

      # Cloud-config as a string
      # TODO not ideal as we should interpolate secrets to avoid putting them to the Nix store
      cloudConfig = lib.mkOption {
        type = lib.types.lines;
        description = "Cloud-init style cloud-config YAML content for Auroraboot.";
      };
    };
  };

  config = lib.mkIf cfg.enable (let
    cloudConfigFile = pkgs.writeText "auroraboot-cloud-config.yaml" cfg.cloudConfig;
  in {
    virtualisation.oci-containers.backend = "podman";

    # Ensure Podman macvlan network for AuroraBoot exists (NixOS-style: a small declarative unit).
    systemd.services.auroraboot-podman-macvlan-network = lib.mkIf dnsmasq.enable {
      description = "Ensure Podman macvlan network for AuroraBoot exists";
      wantedBy = ["multi-user.target"];
      before = ["podman-auroraboot.service"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      path = with pkgs; [podman];

      script = ''
        set -euo pipefail

        if ${pkgs.podman}/bin/podman network inspect ${lib.escapeShellArg macvlanNetworkName} >/dev/null 2>&1; then
          exit 0
        fi

        ${pkgs.podman}/bin/podman network create \
          --driver macvlan \
          --opt parent=${lib.escapeShellArg config.networking.defaultGateway.interface} \
          --subnet ${lib.escapeShellArg cfg.macvlan.subnet} \
          --gateway ${lib.escapeShellArg config.networking.defaultGateway.address} \
          ${lib.escapeShellArg macvlanNetworkName}
      '';
    };

    virtualisation.oci-containers.containers.auroraboot = {
      image = "quay.io/kairos/auroraboot";
      extraOptions =
        [
          # Needs to bind low ports like UDP/67 (PXE/DHCP).
          "--cap-add=NET_BIND_SERVICE"
          # AuroraBoot/pxe tooling commonly needs extra network privileges.
          "--cap-add=NET_ADMIN"
          "--cap-add=NET_RAW"
        ]
        ++ lib.optionals dnsmasq.enable [
          "--ip=${cfg.macvlan.ip}"
        ]
        ++ lib.optionals (!dnsmasq.enable) [
          "--net=host"
        ];
      networks = lib.optionals dnsmasq.enable [
        macvlanNetworkName
      ];
      volumes = [
        "${cloudConfigFile}:/config.yaml:ro"
      ];
      # TODO generate a config file: https://kairos.io/docs/reference/auroraboot
      cmd = [
        "--debug"
        "--set"
        "container_image=${cfg.containerImage}"
        "--set"
        "listen_addr=:${toString cfg.listenPort}"
        "--set"
        "netboot_http_port=${toString cfg.netbootListenPort}"
        "--cloud-config"
        "/config.yaml"
      ];
    };

    # Ensure the generated container unit depends on the network being created.
    systemd.services."podman-auroraboot" = lib.mkIf dnsmasq.enable {
      after = ["auroraboot-podman-macvlan-network.service"];
      requires = ["auroraboot-podman-macvlan-network.service"];
    };

    # Host firewall: allow the ports so broadcast/UDP reaches the netns/macvlan too.
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        cfg.listenPort
        cfg.netbootListenPort
      ];
      allowedUDPPorts = [
        67
        69 # TFTP (PXE/netboot initial file fetch)
        4011 # UDP port used for PXE ProxyDHCP on the AuroraBoot host
      ];
    };
  });
}
