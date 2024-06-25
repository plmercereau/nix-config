{hardware, ...}: {
  imports = [hardware.hetzner-arm ../modules/nixos];
  settings = {
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfpP5+ngbZu26pN1SKGeXWDzp4BXS0HVIH3C9bp5CQp";
    publicIP = "135.181.109.160";
  };
}
