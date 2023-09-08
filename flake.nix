{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, agenix }: {
    nixosConfigurations = {

      code = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./common
          ./hosts/servers/code/configuration.nix

          agenix.nixosModules.default
          { environment.systemPackages = [ agenix.packages.x86_64-linux.default ]; }
        ];
      };

      rt-sea = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./common
          ./hosts/routers/rt-sea/configuration.nix

          agenix.nixosModules.default
          { environment.systemPackages = [ agenix.packages.x86_64-linux.default ]; }
        ];
      };

    };
  };
}
