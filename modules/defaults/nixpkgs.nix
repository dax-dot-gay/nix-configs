{ pkgs, ... }:
{
    nixpkgs.overlays = [
        (final: prev: {
            jellyfin = prev.jellyfin.overrideAttrs (oldAttrs: {
                preInstall = ''
                    makeWrapperArgs+=(
                    --add-flags "--ffmpeg ${prev.jellyfin-ffmpeg.outPath}/bin/ffmpeg"
                    --add-flags "--webdir /persistent/jellyfin"
                    )
                '';
            });
        })
    ];
    nixpkgs.config.allowUnfree = true;
}
