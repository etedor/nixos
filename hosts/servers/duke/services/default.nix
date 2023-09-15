{ ... }:

{
  imports = [
    ./acme
    ./docker
    ./nginx
    ./restic
    ./samba
    ./zfs
  ];

  services.openssh.enable = true;
}
