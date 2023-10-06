{ ... }:

{
  imports = [
    ./acme
    ./ddi
    ./docker
    ./nginx
    ./restic
    ./samba
    ./zfs
  ];

  services.openssh.enable = true;
}
