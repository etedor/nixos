{ config, pkgs, ... }:

let
  zone = config.lib.globals.zone;
in
{
  age.secrets = {
    code-mailgun = {
      file = ../../../../../secrets/code-mailgun.age;
      mode = "400";
      owner = "root";
      group = "root";
    };
  };

  programs.msmtp = {
    enable = true;
    setSendmail = true;

    defaults = {
      tls = true;
      tls_starttls = true;
      tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
    };

    accounts = {
      default = {
        host = "smtp.mailgun.org";
        port = 587;
        auth = true;
        from = "system@mg.${zone}";
        user = "system@mg.${zone}";
        passwordeval = "cat ${config.age.secrets.code-mailgun.path}";
      };
    };
  };
}
