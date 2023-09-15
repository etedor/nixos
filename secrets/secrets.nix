let
  # user keys
  eric_machina = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgNd8ZgyJiay+vUZxvOzXqNsbmjhqzwFZx1U3+LnAVz";
  eric_code = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJ9Ya8PpfcuSHtX52hJUXMDFJwUUyJR+0s6FuSTfEKn";
  eric_duke = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOu8kbwE6phergM4akwVvxsiTyq/aJlWYOHYc7I4h8nA";
  eric = [ eric_machina eric_duke eric_code ];

  # host keys
  code = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFVyPMj/Xq3Nxha/vj1S9xCaEWQMcjsweLpMeDDFjzmN";
  duke = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAF4Hqb6luc7cU27HlOYM73wiSTw44lyik5iuZvBlnjg";
  rt-sea = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHqcrgjHPx1SbllfVSCLcj/g29HAW/qcv6i6ZYoNs99h";
  common = [ code duke rt-sea ];
in
{
  "common/mailgun.age".publicKeys = eric ++ common;
  "duke/acme.age".publicKeys = eric ++ [ code duke ];
  "duke/restic-pass.age".publicKeys = eric ++ [ code duke ];
  "duke/restic-repo.age".publicKeys = eric ++ [ code duke ];
  "rt-sea/wg0-private-key.age".publicKeys = eric ++ [ rt-sea ];
  "rt-sea/wg1-private-key.age".publicKeys = eric ++ [ rt-sea ];
}
