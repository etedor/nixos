{ config, pkgs, ... }:

let
  zone = config.lib.globals.zone;
in
{
  age.secrets = {
    deus-acme = {
      file = ../../../../../secrets/deus-acme.age;
      mode = "400";
      owner = "acme";
      group = "acme";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@${zone}";

    certs."${zone}" = {
      domain = "${zone}";
      extraDomainNames = [ "*.${zone}" ];
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
      credentialsFile = config.age.secrets.deus-acme.path;
    };
  };
}
