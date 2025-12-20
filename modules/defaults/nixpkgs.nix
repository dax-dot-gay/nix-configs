{ pkgs, ... }:
{
    nixpkgs.overlays = [
        (final: prev: {
            jellyfin-web = prev.jellyfin-web.overrideAttrs (oldAttrs: {
                installPhase = ''
                    runHook preInstall

                    mkdir -p $out/share
                    cp -a dist $out/share/jellyfin-web

                    mkdir -p /persistent/jellyfin
                    cp $out/share/jellyfin-web /persistent/jellyfin
                    chown -R jellyfin:jellyfin /persistent/jellyfin

                    runHook postInstall
                '';
            });
            jellyfin = prev.jellyfin.overrideAttrs (oldAttrs: {
                preInstall = ''
                    makeWrapperArgs+=(
                    --add-flags "--ffmpeg ${prev.jellyfin-ffmpeg}/bin/ffmpeg"
                    --add-flags "--webdir /persistent/jellyfin"
                    )
                '';
            });
        })
    ];
    nixpkgs.config.allowUnfree = true;
}
