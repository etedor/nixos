{
  description = "My NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, agenix }: {
    nixosConfigurations =
      let
        overlay-unstable = final: prev: {
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};
        };

        commonModules = [
          ./common
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          agenix.nixosModules.default
          { environment.systemPackages = [ agenix.packages.x86_64-linux.default ]; }
        ];
      in
      {
        code = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules ++ [ ./hosts/servers/code/configuration.nix ];
        };

        rt-sea = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules ++ [ ./hosts/routers/rt-sea/configuration.nix ];
        };
      };
  };
}
