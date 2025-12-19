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
    ];

    system.stateVersion = "25.11";
    nixpkgs.config.allowUnfree = true;
}
