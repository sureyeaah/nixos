{
  description = "sureyeaah's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    home-manager.url = "github:nix-community/home-manager";
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, home-manager, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      latest = inputs.nixpkgs-master.legacyPackages.${system};
      mkHomeMachine = configurationNix: extraModules: nixpkgs.lib.nixosSystem {
        inherit system;
        # Arguments to pass to all modules.
        specialArgs = { inherit system inputs latest; };
        modules = ([
          # System configuration
          configurationNix

          # Features common to all of my machines
          ./features/fonts

          # home-manager configuration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.sureyeaah = import ./home.nix {
              inherit inputs system latest;
              pkgs = import nixpkgs { inherit system; };
            };
          }
        ] ++ extraModules);
      };
    in
    {
      nixosConfigurations.vbox = mkHomeMachine
        ./hosts/vbox.nix
        [
          ./HM/xmonad
        ];

      nixosConfigurations.dell = mkHomeMachine
        ./hosts/dell.nix
        [
          ./HM/xmonad
        ];
      nixosConfigurations.relicx-xps13= mkHomeMachine
        ./hosts/xps13.nix
        [
          inputs.nixos-hardware.nixosModules.dell-xps-13-9310
          ./HM/xmonad
        ];
    };
}
