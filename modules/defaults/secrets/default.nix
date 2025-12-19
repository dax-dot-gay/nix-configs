{
    pkgs,
    ...
}:
{
    imports = [ ./util.nix ];
    environment.systemPackages = [
        pkgs.sops
        pkgs.ssh-to-age
        pkgs.age
    ];

    secrets = {
        enable = true;
        secrets = {
            password.neededForUsers = true;
            acme = {
                hosts = [ "infra-nginx" ];
                owner = "acme";
            };
            "matrix/turn/username" = {
                owner = "matrix-synapse";
                hosts = [ "services-matrix" ];
                mode = "0444";
            };
            "matrix/turn/credential" = {
                owner = "matrix-synapse";
                hosts = [ "services-matrix" ];
                mode = "0444";
            };
            "matrix/matrix-authentication/secret" = {
                owner = "matrix-authentication-service";
                hosts = [ "services-matrix" ];
                mode = "0444";
            };
            "matrix/matrix-authentication/config.yaml" = {
                owner = "matrix-authentication-service";
                hosts = [ "services-matrix" ];
                mode = "0444";
            };
            "matrix/synapse.yaml" = {
                owner = "matrix-synapse";
                hosts = [ "services-matrix" ];
                mode = "0444";
            };
            "jellyfin/jellarr_key" = {
                hosts = [ "services-jellyfin" ];
                mode = "0444";
            };
            "jellyfin/admin_password" = {
                hosts = [ "services-jellyfin" ];
            };
        };
    };
}
