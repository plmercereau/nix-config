{
  config,
  hardware,
  ...
}: {
  imports = [hardware.raspberrypi-4 ../modules/nixos];

  settings = {
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOJHOROkjkRpE/tlzhekhd4O2sMJKnBNycC/T87h+63D";
    localIP = "10.136.1.77";
    impermanence.enable = true;
  };
}
