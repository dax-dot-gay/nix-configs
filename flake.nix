{
    inputs = {
        nixpkgs.url = "nixos/nixos-25.11";
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
        { self, nixpkgs, ... }@inputs:
        let
            system = "x86_64-linux";
            pkgs = import nixpkgs { inherit system; };
        in
        {
            devshells.${system}.default = pkgs.mkShell {
                packages = with pkgs; [
                    sops
                    nixos-generators
                    git
                    ssh-to-age
                    age
                ];
            };
        };
}
