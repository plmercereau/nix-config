{
  config,
  hardware,
  ...
}: {
  imports = [hardware.raspberrypi-4];

  settings = {
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOJHOROkjkRpE/tlzhekhd4O2sMJKnBNycC/T87h+63D";
    networking = {
      localIP = "10.136.1.77";
      vpn.publicKey = "16u3+D45pngM5UPMNxoxZkfd+CYAwLjfqGIadMMkAwQ=";
      vpn.id = 4;
    };
    system.impermanence.enable = true;
  };
}
