{ ... }:

{
  imports = [
    ./acme
    ./docker
    ./nginx
    ./restic
    ./zfs
  ];

  services.openssh.enable = true;
}
