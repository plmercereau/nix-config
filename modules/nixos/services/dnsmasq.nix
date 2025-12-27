{
  config,
  modulesPath,
  pkgs,
  lib,
  ...
}: let
  interfaceName = "enp86s0";
  lanDomain = "lan";

  cfg = config.services.dnsmasq;
  interface = config.networking.interfaces.${interfaceName};
  firstInterfaceIp = lib.elemAt interface.ipv4.addresses 0;
  firstIp = firstInterfaceIp.address;
  hostname = config.networking.hostName;
in {
  services.dnsmasq = lib.mkIf cfg.enable {
    settings = {
      interface = config.networking.defaultGateway.interface;
      bind-interfaces = true;

      # Default route given to clients
      dhcp-option = [
        "option:router,${config.networking.defaultGateway.address}"
        "option:dns-server,${firstIp}"
        # TODO not sure this is needed for auroraboot
        "option:tftp-server,192.168.0.3"
        "option:domain-name,${lanDomain}"
        "option:domain-search,${lanDomain}"
      ];
      host-record = [
        # TODO compute this
        "${hostname}.${lanDomain},${firstIp}"
      ];
      domain = lanDomain;
      local = "/${lanDomain}/";
      server = [
        "1.1.1.1"
        "8.8.8.8"
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
