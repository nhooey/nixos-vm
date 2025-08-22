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
    in
    {
      packages = eachSystem (system: {
        vmware = nixos-generators.nixosGenerate {
          system = "${system}";
          format = "vmware";
          modules = [
            ./configuration.nix
          ];

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
          modules = [
            ./configuration.nix
          ];
        };
      });
    };
}
