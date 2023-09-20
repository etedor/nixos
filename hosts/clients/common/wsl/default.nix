{ ... }:

{
  imports = [
    ./services
  ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "eric";
    startMenuLaunchers = true;
  };
}
