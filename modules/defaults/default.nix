{ ... }:
{
    imports = [
        ./openssh.nix
        ./secrets.nix
        ./users.nix
        ./terminal.nix
        ./networking.nix
    ];

    system.stateVersion = "25.11";
}
