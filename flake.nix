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
        jellarr = {
            url = "github:venkyr77/jellarr";
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
            daxlib = import ./lib;

            mkVM =
                {
                    hostname,
                    path,
                    extraModules ? [ ],
                    include ? [ ],
                }:
                nixpkgs.lib.nixosSystem {
                    system = "${system}";
                    specialArgs = inputs // {
                        hostname = "${hostname}";
                        repository = repository;
                        daxlib = daxlib;
                    };
                    modules = [
                        ./modules/defaults
                        ./modules/systems/vm.nix
                        ./systems/${path}/configuration.nix
                        inputs.sops-nix.nixosModules.sops
                        inputs.disko.nixosModules.disko
                        inputs.comin.nixosModules.comin
                    ]
                    ++ extraModules
                    ++ (builtins.map (inc: ./modules/${inc}) include);
                };

            mkLXC =
                {
                    hostname,
                    path,
                    extraModules ? [ ],
                    include ? [ ],
                }:
                nixpkgs.lib.nixosSystem {
                    system = "${system}";
                    specialArgs = inputs // {
                        hostname = "${hostname}";
                        repository = repository;
                        daxlib = daxlib;
                    };
                    modules = [
                        ./modules/defaults
                        ./modules/systems/lxc.nix
                        ./systems/${path}/configuration.nix
                        inputs.sops-nix.nixosModules.sops
                        inputs.comin.nixosModules.comin
                    ]
                    ++ extraModules
                    ++ (builtins.map (inc: ./modules/${inc}) include);
                };
        in
        {
            nixosConfigurations = {
                base-vm = mkVM {
                    hostname = "base-vm";
                    path = "base/vm";
                    include = [ "features/nfs-client.nix" ];
                };
                base-lxc = mkLXC {
                    hostname = "base-lxc";
                    path = "base/lxc";
                    include = [ "features/nfs-client.nix" ];
                };
                infra-nfs = mkLXC {
                    hostname = "infra-nfs";
                    path = "infra/nfs";
                };
                infra-nginx = mkLXC {
                    hostname = "infra-nginx";
                    path = "infra/nginx";
                };
                services-access = mkLXC {
                    hostname = "services-access";
                    path = "services/access";
                    include = [ "features/nfs-client.nix" ];
                };
                services-matrix = mkLXC {
                    hostname = "services-matrix";
                    path = "services/matrix";
                    include = [ "features/podman.nix" ];
                };
                services-jellyfin = mkVM {
                    hostname = "services-jellyfin";
                    path = "services/jellyfin";
                    extraModules = [ inputs.jellarr.nixosModules.default ];
                    include = [ "features/nfs-client.nix" ];
                };
                services-romm = mkLXC {
                    hostname = "services-romm";
                    path = "services/romm";
                    include = [ "features/podman.nix" "features/nfs-client.nix" ];
                };
            };
        };
}
