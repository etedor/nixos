{ ... }:

{
  system.stateVersion = "23.05";

  imports = [
    ../common/wsl
  ];

  networking = {
    hostName = "machina";
  };
}
