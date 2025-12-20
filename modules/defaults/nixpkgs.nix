{ pkgs, ... }:
{
    nixpkgs.overlays = [
        (final: prev: {
            jellyfin-web = prev.jellyfin-web.overrideAttrs (oldAttrs: {
                installPhase = ''
                    runHook preInstall

                    mkdir -p $out/share
                    cp -a dist $out/share/jellyfin-web

                    mkdir -p /var/lib/jellyfin-web
                    cp $out/share/jellyfin-web /var/lib/jellyfin-web
                    chown -R jellyfin:jellyfin /var/lib/jellyfin-web

                    runHook postInstall
                '';
            });
            jellyfin = prev.jellyfin.overrideAttrs (oldAttrs: {
                preInstall = ''
                    makeWrapperArgs+=(
                    --add-flags "--ffmpeg ${prev.jellyfin-ffmpeg}/bin/ffmpeg"
                    --add-flags "--webdir /var/lib/jellyfin-web"
                    )
                '';
            });
        })
    ];
    nixpkgs.config.allowUnfree = true;
}
