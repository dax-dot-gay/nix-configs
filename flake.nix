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
    };

    outputs =
        {
            self,
            nixpkgs,
            comin,
            config,
            nixos-generators,
            ...
        }@inputs:
        let
            system = "x86_64-linux";
            pkgs = import nixpkgs { inherit system; };
            repository = "https://github.com/dax-dot-gay/nix-configs.git";
        in
        {
            nixosConfigurations = {
                
            };

            packages.${system} = {
                base-vm = nixos-generators.nixosGenerate {
                    system = "${system}";
                    format = "proxmox";
                    specialArgs = {
                        pkgs = pkgs;
                    };
                    modules = [
                        ./systems/base_vm.nix
                    ];
                };
            };
        };
}
