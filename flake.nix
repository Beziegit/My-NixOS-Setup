{
  description = "NixOS configuration with CachyOS Kernel + SteamNix (Jovian)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-cachyos-kernel, jovian, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        jovian.nixosModules.default

        # CachyOS kernel
        ({ pkgs, ... }: {
          boot.kernelPackages = nix-cachyos-kernel.legacyPackages.${pkgs.system}.linuxPackages-cachyos-latest;
        })
      ];
    };
  };
}
