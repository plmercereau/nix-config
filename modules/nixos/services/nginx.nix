{
  config,
  modulesPath,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.nginx;
  radarr = config.services.radarr;
  prowlarr = config.services.prowlarr;
  sonarr = config.services.sonarr;
  bazarr = config.services.bazarr;
  jellyfin = config.services.jellyfin;
  transmission = config.services.transmission;
in {
  config = lib.mkIf cfg.enable {
    # networking.firewall.allowedTCPPorts = [80 443];

    # services.nginx = {
    #   recommendedTlsSettings = true;
    #   recommendedOptimisation = true;
    #   recommendedGzipSettings = true;
    #   recommendedProxySettings = true;

    #   virtualHosts.${config.networking.hostName}.locations = lib.mkIf cfg.enable {
    #     "/" = {
    #       root = index.outPath;
    #       index = "index.html";
    #     };
    #   };
    # };
  };
}
