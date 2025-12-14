{
    pkgs,
    config,
    nixpkgs,
    ...
}:
{
    nix.registry.nixpkgs.flake = nixpkgs;
    environment.systemPackages = with pkgs; [
        zsh
        zsh-completions
        zsh-autosuggestions
    ];
}
