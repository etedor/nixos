{ lib }:

let
  concatStringsSep = builtins.concatStringsSep;
  optionalString = lib.optionalString;

  mkSet = list:
    "{ ${concatStringsSep ", " list} }";

  mkRule = attrs:
    let
      # Mandatory attributes
      name = if attrs ? name then attrs.name else throw "The 'name' attribute is mandatory!";
      action = if attrs ? action then attrs.action else throw "The 'action' attribute is mandatory!";

      iif = optionalString (attrs ? "iif") "iifname ${mkSet attrs.iif}";
      oif = optionalString (attrs ? "oif") "oifname ${mkSet attrs.oif}";
      sip = optionalString (attrs ? "sip") "ip saddr ${attrs.sip}";
      dip = optionalString (attrs ? "dip") "ip daddr ${attrs.dip}";
      sport = optionalString (attrs ? "sport") "${attrs.proto} sport ${toString attrs.sport}";
      dport = optionalString (attrs ? "dport") "${attrs.proto} dport ${toString attrs.dport}";

      comment = "comment \"${attrs.name}\"";
    in
    "${iif} ${oif} ${sip} ${sport} ${dip} ${dport} ${attrs.action} ${comment}";
in
mkRule
