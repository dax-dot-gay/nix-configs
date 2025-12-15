{ ... }:
{
    imports = [
        ./openssh.nix
        ./secrets.nix
        ./users.nix
    ];

    system.stateVersion = "25.11";
}
