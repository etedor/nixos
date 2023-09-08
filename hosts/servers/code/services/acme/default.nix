{ config, pkgs, ... }:

let
  zone = config.lib.globals.zone;
in
{
  age.secrets = {
    code-acme = {
      file = ../../../../../secrets/code-acme.age;
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
      credentialsFile = config.age.secrets.code-acme.path;
    };
  };
}
