{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    systems.url = "github:nix-systems/default-linux";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, systems, nixos-generators, ... }@inputs:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);

      nodes = [
        {
          name = "localdev";
          hostname = "localdev";
          vm-formats = [ "vmware" "raw-efi" ];
        }
      ];

      inherit (import ./nix/util/expandAttrs.nix { }) expandAttrs;

      gen-image = (hostname: system: vm-format:
        nixos-generators.nixosGenerate {
          inherit system;
          format = vm-format;
          modules = [
            ./nix/common.nix
            ./nix/configuration.nix
          ];
          specialArgs = {
            self = self;
            nodeHostName = hostname;
          };
        });

      gen-config = (hostname: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./nix/common.nix
            ./nix/configuration.nix

            # Duplicate subset of `raw-efi.nix` from upstream `nixos-generators`
            # to get `nixos-rebuild` working
            ./nix/raw-efi.nix
          ];
          specialArgs = {
            self = self;
            nodeHostName = hostname;
          };
        });

    in
    {
      # Flake packages must be structured by system: packages.<system>.<name> = derivation
      packages = eachSystem (system:
        builtins.listToAttrs (
          builtins.concatMap
            (e:
              builtins.map
                (vm-format: {
                  name = "${e.name}_${vm-format}";
                  value = gen-image e.hostname system vm-format;
                })
                e.vm-formats
            )
            nodes));

      # Provide one nixosConfiguration per (name, system); pick raw-efi as canonical to avoid duplicates
      nixosConfigurations =
        builtins.listToAttrs (
          builtins.map
            (e: {
              name = e.hostname;
              value = gen-config e.hostname "aarch64-linux";
            })
            nodes);
    };
}
