{ sops-nix, pkgs, ... }:
{
    environment.systemPackages = [
        pkgs.sops
        pkgs.ssh-to-age
        pkgs.age
    ];
}
