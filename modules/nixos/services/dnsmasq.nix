{
  config,
  modulesPath,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.dnsmasq;
in {
  services.dnsmasq = lib.mkIf cfg.enable {
    settings = {
      interface = config.networking.defaultGateway.interface;
      bind-interfaces = true;

      # Default route given to clients
      dhcp-option = [
        "option:router,${config.networking.defaultGateway.address}"
        "option:dns-server,${config.networking.defaultGateway.address},1.1.1.1,8.8.8.8"
      ];
      # Conservative defaults
      domain-needed = true;
      bogus-priv = true;
    };
  };

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [
      53 # We do not serve DNS queries for now (see dns-server option), so no real need to open the port
      67
    ];
  };
}
