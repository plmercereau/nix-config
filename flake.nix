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

    nicos.url = "github:plmercereau/nicos";
    nicos.inputs = {
      nixpkgs.follows = "nixpkgs";
      home-manager.follows = "home-manager";
      flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    nicos,
    flake-utils,
    nixpkgs,
    nix-darwin,
    agenix,
    home-manager,
    ...
  }: let
    # conf = nicos.lib.configure (import ./config.nix) (flake-utils.lib.eachDefaultSystem (system: let
    conf = nicos.lib.configure ((import ./config.nix) // {extraModules = [./shared.nix];}) (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # Use the devShells of the nicos flake
      devShells = {
        inherit (nicos.devShells.${system}) default;
      };

      apps = {
        # Shortcut to call the cli using `nix run .`
        inherit (nicos.apps.${system}) default;

        # Browse the flake using nix repl
        repl = flake-utils.lib.mkApp {
          drv = pkgs.writeShellApplication {
            name = "repl";
            runtimeInputs = [pkgs.jq];
            text = ''
              flake_url=$(nix flake metadata --json --no-write-lock-file --quiet | jq -r '.url')
              nix repl --expr "builtins.getFlake \"$flake_url\""
            '';
          };
        };
      };
    }));
  in (conf
    // {
      darwinConfigurations = let
        specialArgs = {
          inherit (conf) nixosConfigurations;
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
    });
}
