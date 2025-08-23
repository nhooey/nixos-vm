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

      nodes = [ "localdev" ];

      gen-image = (nodename: system:
        nixos-generators.nixosGenerate {
          inherit system;
          format = "raw-efi";
          modules = [
            ./nix/common.nix
          ];
          specialArgs = {
            self = self;
            nodeHostName = nodename;
          };
        });
      gen-config = (nodename: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./nix/common.nix

            # Duplicate subset of `raw-efi.nix` from upstream `nixos-generators`
            # to get `nixos-rebuild` working
            ./nix/raw-efi.nix
          ];
          specialArgs = {
            self = self;
            nodeHostName = nodename;
          };
        });
    in
    {
      packages = eachSystem (system: builtins.listToAttrs (
        map
          (nodename: { "name" = nodename; "value" = gen-image nodename system; })
          (nodes)
      ));

      nixosConfigurations = eachSystem (system: builtins.listToAttrs (
        map
          (nodename: { "name" = nodename; "value" = gen-config nodename system; })
          (nodes)
      ));
    };
}
