{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    systems = {
      url = "github:nix-systems/default-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, systems, flake-utils, nixos-generators, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system: {
      packages.${system} = {
        vmware = nixos-generators.nixosGenerate {
          system = "${system}";
          modules = [
            ./configuration.nix
          ];
          format = "vmware";

          # optional arguments:
          # explicit nixpkgs and lib:
          # pkgs = nixpkgs.legacyPackages.x86_64-linux;
          # lib = nixpkgs.legacyPackages.x86_64-linux.lib;
          # additional arguments to pass to modules:
          # specialArgs = { myExtraArg = "foobar"; };

          # you can also define your own custom formats
          # customFormats = { "myFormat" = <myFormatModule>; ... };
          # format = "myFormat";
        };
        vbox = nixos-generators.nixosGenerate {
          system = "${system}";
          format = "virtualbox";
        };
      };
    });
}
