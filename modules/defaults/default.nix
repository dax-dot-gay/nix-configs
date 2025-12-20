{ ... }:
{
    imports = [
        ./openssh.nix
        ./secrets
        ./users.nix
        ./terminal.nix
        ./networking.nix
        ./nixos.nix
        ./comin.nix
        ./upgrades.nix
        ./ensure_paths.nix
        ./nixpkgs.nix
    ];

    system.stateVersion = "25.11";
}
