{ lib, ... }:

{
  lib.locals = {
    rt-sea = {
      domainName = "int.et42.net";

      extIntf = "ens3";
      localAs = 65099;
      routerId = "10.127.99.1";
    };
  };
}
