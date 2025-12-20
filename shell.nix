let
    nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-25.11";
    pkgs = import nixpkgs {
        config = { };
        overlays = [ ];
    };
in

pkgs.mkShellNoCC {
    packages = with pkgs; [
        sops
        nixos-generators
        git
        ssh-to-age
        age
        yq-go
        compose2nix
        podman
        podman-compose
    ];

    shellHook = ''
        export PATH="$PATH:./scripts"
    '';
}
