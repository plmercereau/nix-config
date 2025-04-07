{
  description = "Flake for managing my machines";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    # (Hint: don't use nixos-unstable-small when enabling the linux-builder on a darwin)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs = {
      nixpkgs.follows = "nixpkgs";
      home-manager.follows = "home-manager";
    };
  };

  outputs = {
    flake-utils,
    nixpkgs,
    nix-darwin,
    agenix,
    home-manager,
    ...
  }:
    (flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          shellHook = ''
            echo "Welcome to the Nix config flake"
          '';
        };
      }
    ))
    // {
      darwinConfigurations = let
        specialArgs = {
          # inherit (conf) nixosConfigurations;
          inherit agenix;
        };
      in {
        badger = nix-darwin.lib.darwinSystem rec {
          modules = [
            ./modules/darwin
            ./hosts-darwin/badger.nix
            agenix.darwinModules.default
            home-manager.darwinModules.home-manager
            {
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
          inherit specialArgs;
        };
      };
    };
}
