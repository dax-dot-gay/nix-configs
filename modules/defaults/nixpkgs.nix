{ pkgs, ... }:
{
    nixpkgs.overlays = [
        (final: prev: {
            jellyfin = prev.jellyfin.override {jellyfin-web = "/persistent/jellyfin";};
        })
    ];
    nixpkgs.config.allowUnfree = true;
}
