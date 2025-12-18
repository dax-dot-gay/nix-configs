{ pkgs, ... }:
{
    environment.systemPackages = [
        pkgs.sops
        pkgs.ssh-to-age
        pkgs.age
    ];

    sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        age.sshKeyPaths = [ "/persistent/ssh/id_ed25519" ];

        secrets = {
            password.neededForUsers = true;
            acme.neededForUsers = true;
            "matrix/turn/username" = {
                neededForUsers = true;
                owner = "matrix-synapse";
                mode = "666";
            };
            "matrix/turn/credential" = {
                neededForUsers = true;
                owner = "matrix-synapse";
                mode = "666";
            };
            "matrix/matrix-authentication/secret" = {
                neededForUsers = true;
                owner = "matrix-authentication-service";
                mode = "666";
            };
            "matrix/matrix-authentication/config.yaml" = {
                neededForUsers = true;
                owner = "matrix-authentication-service";
                mode = "666";
            };
        };
    };
}
