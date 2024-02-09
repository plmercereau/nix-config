{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.linux-builder;
in {
  options = {
    custom.linux-builder = {
      enable = mkOption {
        description = ''
          Whether to run a virtual linux builder on the host machine.

          <Warning>If no Nix builder is available for Linux with the host's processor, you must first build with the `services.linux-builder.initialBuitd` option enabled.</Warning>
        '';
        type = types.bool;
        default = false;
      };
      initialBuild = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to activate the initial linux-builder from the nixpkgs cache.

          On the first run, the Linux builder needs to be created. Unless there is a corresponding nix builder set up,
          the Darwin host won't be able to build the Linux builder with its custom configuraiton.

          This option allows to disable the custom configuration of the linux-builder,
          so that the Linux builder can be installed from the official cache.

          Once the Linux builder is on, it is available as a build itself, and the option can then be disabled
          so the host machine can rebuild it again with the custom configuration.
        '';
      };
    };
  };
  config.nix.linux-builder = mkIf cfg.enable {
    # Create a Linux remote builder that works out of the box
    # * nix-darwin option: https://github.com/LnL7/nix-darwin/blob/master/modules/nix/linux-builder.nix
    # * darwin-builder: https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/profiles/macos-builder.nix
    enable = true;
    config = mkIf (!cfg.initialBuild) ({pkgs, ...}: {
      virtualisation.diskSize = lib.mkForce (1024 * 40); # 40GB, defaults seems to be 20GB
      users.users.builder = {
        # * add the admin ssh keys into the linux-builder so the project admins can connect to it without using the /etc/nix/builder_ed25519 identity
        # TODO
        # openssh.authorizedKeys.keys = config.lib.ext_lib.adminKeys;
        # * the builder user needs to be in the wheel group to be able to mount iso images
        extraGroups = ["wheel"];
      };
      security.sudo.wheelNeedsPassword = false;
    });
  };
}
