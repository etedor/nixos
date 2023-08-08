{ config }:

let
  mkPorts = cfg:
    let
      netdevs = builtins.attrValues cfg.systemd.network.netdevs;
    in
    builtins.map (netdev: netdev.wireguardConfig.ListenPort) netdevs;
in
{
  ports = mkPorts config;
}
