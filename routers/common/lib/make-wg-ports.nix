{ config }:

let
  mappedAttrs = builtins.mapAttrs (name: value: value.wireguardConfig.ListenPort) config.systemd.network.netdevs;
  attrValues = builtins.attrValues mappedAttrs;
  stringValues = builtins.map toString attrValues;
  concatenatedStrings = builtins.concatStringsSep ", " stringValues;
  wgPorts = "{ ${concatenatedStrings} }";
in
wgPorts
