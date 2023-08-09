let
  # user keys
  eric_machina = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgNd8ZgyJiay+vUZxvOzXqNsbmjhqzwFZx1U3+LnAVz";
  eric_nix-vscode = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJ9Ya8PpfcuSHtX52hJUXMDFJwUUyJR+0s6FuSTfEKn";
  eric = [ eric_machina eric_nix-vscode ];

  # host keys
  nix-vscode = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFVyPMj/Xq3Nxha/vj1S9xCaEWQMcjsweLpMeDDFjzmN";
  rt-sea = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHqcrgjHPx1SbllfVSCLcj/g29HAW/qcv6i6ZYoNs99h";
in
{
  "rt-sea-wg0.age".publicKeys = eric ++ [ rt-sea ];
  "rt-sea-wg1.age".publicKeys = eric ++ [ rt-sea ];
}
