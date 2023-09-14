{ config, ... }:

{
  age.secrets =
    let
      secretsPath = ../../../../../secrets;
    in
    {
      wg0-private-key = { file = "${secretsPath}/rt-sea/wg0-private-key.age"; mode = "444"; };
      wg1-private-key = { file = "${secretsPath}/rt-sea/wg1-private-key.age"; mode = "444"; };
    };

  systemd.network =
    let
      wg = import ../../../common/lib/wireguard { inherit config; };
    in
    {
      netdevs = {
        "10-wg0" = {
          netdevConfig = { Name = "wg0"; Kind = "wireguard"; };
          wireguardConfig = {
            PrivateKeyFile = config.age.secrets.wg0-private-key.path;
            ListenPort = 51820;
          };
          wireguardPeers = [{
            wireguardPeerConfig = {
              PublicKey = wg.publicKeys.vyos-ggz.wg0;
              AllowedIPs = [ "0.0.0.0/0" ];
            };
          }];
        };

        "20-wg1" = {
          netdevConfig = { Name = "wg1"; Kind = "wireguard"; };
          wireguardConfig = {
            PrivateKeyFile = config.age.secrets.wg1-private-key.path;
            ListenPort = 51821;
          };
          wireguardPeers = [
            {
              wireguardPeerConfig = {
                # pine
                PublicKey = wg.publicKeys.pine.wg0;
                AllowedIPs = [ "10.99.1.11/32" ];
              };
            }
            {
              wireguardPeerConfig = {
                # et
                PublicKey = wg.publicKeys.et.wg0;
                AllowedIPs = [ "10.99.1.12/32" ];
              };
            }
          ];
        };
      };

      networks = {
        "10-wg0" = { matchConfig.Name = "wg0"; address = [ "10.99.0.0/31" ]; };
        "20-wg1" = { matchConfig.Name = "wg1"; address = [ "10.99.1.1/24" ]; };
      };
    };
}
