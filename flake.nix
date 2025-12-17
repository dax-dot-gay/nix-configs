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

            mkVM = {hostname, path, extraModules ? []}: nixpkgs.lib.nixosSystem {
                system = "${system}";
                specialArgs = inputs // {hostname = "${hostname}"; repository = repository; };
                modules = [
                    ./modules/defaults
                    ./modules/systems/vm.nix
                    ./systems/${path}/configuration.nix
                    inputs.sops-nix.nixosModules.sops
                    inputs.disko.nixosModules.disko
                    inputs.comin.nixosModules.comin
                ] ++ extraModules;
            };

            mkLXC = {hostname, path, extraModules ? []}: nixpkgs.lib.nixosSystem {
                system = "${system}";
                specialArgs = inputs // {hostname = "${hostname}"; repository = repository; };
                modules = [
                    ./modules/defaults
                    ./modules/systems/lxc.nix
                    ./systems/${path}/configuration.nix
                    inputs.sops-nix.nixosModules.sops
                    inputs.comin.nixosModules.comin
                ] ++ extraModules;
            };
        in
        {
            nixosConfigurations = {
                base-vm = mkVM {hostname = "base-vm"; path = "base/vm";};
                base-lxc = mkLXC {hostname = "base-lxc"; path = "base/lxc";};
                infra-nfs = mkLXC {hostname = "infra-nfs"; path = "infra/nfs";};
            };
        };
}
