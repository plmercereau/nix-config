{
  description = "Flake for managing my machines";

  inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    flake-utils.url = "github:numtide/flake-utils";

    # (Hint: don't use nixos-unstable-small when enabling the linux-builder on a darwin)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs = {
      nixpkgs.follows = "nixpkgs";
      home-manager.follows = "home-manager";
    };

    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    nix-darwin,
    agenix,
    home-manager,
    srvos,
    disko,
    nixos-facter-modules,
    deploy-rs,
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
      darwinConfigurations = {
        badger = nix-darwin.lib.darwinSystem rec {
          modules = [
            ./modules/darwin
            ./hosts-darwin/badger.nix
            agenix.darwinModules.default
            home-manager.darwinModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                # TODO check in the latest home-manager version if this is still needed
                inherit agenix;
              };
            }
          ];
          specialArgs = {
            inherit agenix;
          };
        };
      };
      nixosConfigurations = {
        # Test:
        # nix run github:nix-community/nixos-anywhere -- --flake .#fennec --vm-test
        # Config
        # nix run github:nix-community/nixos-anywhere -- --flake .#fennec --generate-hardware-config nixos-facter ./hosts-nixos/fennec-facter.json
        # Install
        # nix run github:nix-community/nixos-anywhere -- --flake .#fennec --target-host root@192.168.1.242
        # Update
        # nixos-rebuild switch --flake .#fennec --target-host root@192.168.1.242
        # nix run github:serokell/deploy-rs .#fennec
        fennec = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            # This machine is a server
            srvos.nixosModules.server
            # Configured with extra terminfos
            srvos.nixosModules.mixins-terminfo
            srvos.nixosModules.mixins-nginx
            srvos.nixosModules.mixins-mdns
            ./modules/nixos
            ./hosts-nixos/fennec.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            nixos-facter-modules.nixosModules.facter
            {config.facter.reportPath = ./hosts-nixos/fennec-facter.json;}
            {
              home-manager.extraSpecialArgs = {inherit agenix;};
            }
          ];
          specialArgs = {
            inherit agenix;
          };
        };
      };

      deploy.nodes.fennec = {
        hostname = "fennec.home";
        remoteBuild = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.fennec;
        };
      };

      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
