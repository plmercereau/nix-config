{
  config,
  modulesPath,
  pkgs,
  lib,
  ...
}: let
  radarr = config.services.radarr;
  prowlarr = config.services.prowlarr;
  sonarr = config.services.sonarr;
  bazarr = config.services.bazarr;
  nginx = config.services.nginx;
  jellyseerr = config.services.jellyseerr;
in {
  /*
  TODO declarative configuration for radarr and prowlarr, in particular:
  - change "baseURL" in both apps to "/radarr" and "/prowlarr" respectively
  - configure clients e.g. aria2, transmission, etc.
  - connnect radarr/sonarr with prowlarr
  - configure indexers
  - directories
  - secrets
  */
  services.jellyseerr = lib.mkIf jellyseerr.enable {
    openFirewall = true;
    port = 5055; # default port
  };

  services.radarr = lib.mkIf radarr.enable {
    openFirewall = true;
  };
  services.sonarr = lib.mkIf sonarr.enable {
    openFirewall = true;
  };
  services.bazarr = lib.mkIf bazarr.enable {
    openFirewall = true;
  };
  services.prowlarr = lib.mkIf prowlarr.enable {
    openFirewall = true;
  };
  services.nginx.virtualHosts.${config.networking.hostName}.locations = {
    "/radarr" = lib.mkIf (nginx.enable && radarr.enable) {
      proxyPass = "http://127.0.0.1:7878";
      recommendedProxySettings = true;
    };
    "/radarr(/[0-9]+)?/api" = lib.mkIf (nginx.enable && radarr.enable) {
      proxyPass = "http://127.0.0.1:7878";
    };
    "/sonarr" = lib.mkIf (nginx.enable && sonarr.enable) {
      proxyPass = "http://127.0.0.1:8989";
      recommendedProxySettings = true;
    };
    "/sonarr(/[0-9]+)?/api" = lib.mkIf (nginx.enable && sonarr.enable) {
      proxyPass = "http://127.0.0.1:8989";
    };
    "/prowlarr" = lib.mkIf (nginx.enable && prowlarr.enable) {
      proxyPass = "http://127.0.0.1:9696";
      recommendedProxySettings = true;
    };
    "/prowlarr(/[0-9]+)?/api" = lib.mkIf (nginx.enable && prowlarr.enable) {
      proxyPass = "http://127.0.0.1:9696";
    };
    "/bazarr" = lib.mkIf (nginx.enable && bazarr.enable) {
      proxyPass = "http://127.0.0.1:6767";
      recommendedProxySettings = true;
    };
    "/bazarr(/[0-9]+)?/api" = lib.mkIf (nginx.enable && bazarr.enable) {
      proxyPass = "http://127.0.0.1:6767";
    };
  };
  systemd.services.radarr = lib.mkIf radarr.enable {
    serviceConfig.UMask = "0007"; # create files with 770 permissions
  };
  systemd.services.sonarr = lib.mkIf sonarr.enable {
    serviceConfig.UMask = "0007"; # create files with 770 permissions
  };
  systemd.services.bazarr = lib.mkIf bazarr.enable {
    serviceConfig.UMask = "0007"; # create files with 770 permissions
  };
}
