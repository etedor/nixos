{ ... }:

let
  user = "eric";
  localPath = "/home/${user}/.ssh";
  remotePath = "/mnt/c/Users/${user}/.ssh";
  keyType = "id_ed25519";
  publicKeyPath = "${remotePath}/${keyType}.pub";
  privateKeyPath = "${remotePath}/${keyType}";
in
{
  system.activationScripts.linkSSH = {
    text = ''
      mkdir -p ${localPath}
      chown ${user}:users ${localPath}
      chmod 700 ${localPath}

      ln -sf ${publicKeyPath} ${localPath}/${keyType}.pub
      ln -sf ${privateKeyPath} ${localPath}/${keyType}

      chown ${user}:users ${localPath}/${keyType}.pub ${localPath}/${keyType}
      chmod 644 ${localPath}/${keyType}.pub
      chmod 600 ${localPath}/${keyType}
    '';
  };
}
