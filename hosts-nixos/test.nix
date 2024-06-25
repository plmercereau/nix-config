{
  hardware,
  config,
  lib,
  ...
}: {
  imports = [hardware.hetzner-x86 ../modules/nixos];
  settings = {
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDl/ES1J/Xs4pbOQd/zsap36M3WWnP34mBy65FwEUT3a ";

    publicIP = "135.181.253.254";

    kubernetes.enable = true;
    local-server.enable = false;
  };
}
