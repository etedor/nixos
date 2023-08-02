{
  description = "My NixOS configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  inputs.agenix.url = "github:ryantm/agenix";

  outputs = { self, nixpkgs, agenix }: {

    nixosConfigurations.nix-vscode = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./common/common.nix
        ./common/home.nix
        ./common/services.nix
        ./hosts/nix-vscode/configuration.nix
        ./hosts/nix-vscode/hardware-configuration.nix
        agenix.nixosModules.default
        {
          environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
        }
      ];
    };

    nixosConfigurations.nix-router-sea = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./common/common.nix
        ./common/home.nix
        ./common/services.nix
        ./common/router/router.nix
        ./hosts/nix-router-sea/configuration.nix
        ./hosts/nix-router-sea/hardware-configuration.nix
        agenix.nixosModules.default
        {
          environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
        }
      ];
    };

  };
}
