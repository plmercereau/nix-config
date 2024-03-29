{
  hardware,
  config,
  ...
}: {
  imports = [hardware.hetzner-x86 ../modules/nixos];
  settings = {
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO0e4xgSR+fNpnLPcB+EGzPYZ4wuCulH36OM0DQTAU5p";

    publicIP = "65.108.88.217";
    vpn.publicKey = "jW/AbaW8SSBKHUdYiSWQKuecN4Z1C04VcEnnin+A5y0=";
    vpn.id = 7;

    kubernetes.enable = true;
  };
}
