{hardware, ...}: {
  imports = [hardware.hetzner-x86 ../modules/nixos];
  settings = {
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfpP5+ngbZu26pN1SKGeXWDzp4BXS0HVIH3C9bp5CQp";
    networking = {
      publicIP = "128.140.39.64";
      vpn = {
        id = 1;
        publicKey = "Juozjo5Mi2zPm0fwhHlo3b5956HtZOw0MxdYWOjA2XU=";
        bastion = {
          enable = true;
          port = 51820;
          extraMachines = {
            badger = {
              # TODO reconfigure
              publicKey = "zNzpca0ysOu3hf7BMahAs8B7Ii7LpBwHcOYaqacG1y8=";
              id = 2;
            };
            puffin = {
              # TODO reconfigure
              publicKey = "cMt59SZfO/YNKNfrcEzzGLTGpKoxH4g/0AR9Iu0eTnE=";
              id = 3;
            };
          };
        };
      };
    };
  };
}
