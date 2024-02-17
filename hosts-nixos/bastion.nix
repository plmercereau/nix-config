{hardware, ...}: {
  imports = [hardware.hetzner-arm ../modules/nixos];
  settings = {
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfpP5+ngbZu26pN1SKGeXWDzp4BXS0HVIH3C9bp5CQp";
    networking = {
      publicIP = "135.181.109.160";
      vpn = {
        id = 1;
        publicKey = "Juozjo5Mi2zPm0fwhHlo3b5956HtZOw0MxdYWOjA2XU=";
        bastion = {
          enable = true;
          port = 51820;
          extraPeers = {
            # TODO it would be great to find a way to generate automatically from lib.configure as a feature e.g. a home-manager module etc.
            pilou = {
              id = 2;
              publicKey = "zNzpca0ysOu3hf7BMahAs8B7Ii7LpBwHcOYaqacG1y8=";
            };
          };
        };
      };
    };
  };
}
