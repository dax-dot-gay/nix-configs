{
    inputs = {
        nixpkgs.url = "nixpkgs/nixos-25.11";
        comin = {
            url = "github:nlewo/comin";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixos-generators = {
            url = "github:nix-community/nixos-generators";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        disko = {
            url = "github:nix-community/disko/latest";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs =
        {
            self,
            nixpkgs,
            ...
        }@inputs:
        let
            system = "x86_64-linux";
            pkgs = import nixpkgs { inherit system; };
            repository = "https://github.com/dax-dot-gay/nix-configs.git";
        in
        {
            nixosConfigurations = {
                base_vm = nixpkgs.lib.nixosSystem {
                    system = "${system}";
                    specialArgs = inputs;
                    modules = [
                        ./modules/default_modules.nix
                        ./modules/systems/vm.nix
                        ./systems/base_vm/configuration.nix
                        inputs.sops-nix.nixosModules.sops
                        inputs.disko.nixosModules.disko
                    ];
                };
            };
        };
}
