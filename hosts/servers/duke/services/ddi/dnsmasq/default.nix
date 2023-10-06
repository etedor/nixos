{ config, pkgs, lib, ... }:

let
  dns = import ./dns.nix;
  mkPtr = host: addr:
    let
      ipParts = lib.splitString "." addr;
      reversedIP = lib.concatStringsSep "." (lib.lists.reverseList ipParts);
    in
    "${reversedIP}.in-addr.arpa,${host}";
  ptrRecords = lib.mapAttrsToList mkPtr dns.static-hosts;
in
{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      domain-needed = true;
      port = "5353";

      address = lib.mapAttrsToList (host: addr: "/${host}/${addr}") dns.static-hosts;
      ptr-record = ptrRecords;
    };
  };
}
