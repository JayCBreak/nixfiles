{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    # use "nixos", or your hostname as the name of the configuration
    # it's a better practice than "default" shown in the video
    nixosConfigurations = {
      jay-topN = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/jay-topN/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      laptopServer = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
	modules = [
          ./hosts/laptopServer/configuration.nix
	  inputs.home-manager.nixosModules.default
	];
      };
      dwagonPC = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
	modules = [
          ./hosts/dwagonPC/configuration.nix
	  inputs.home-manager.nixosModules.default
	];
      };
    };
  };
}
