{ pkgs, config, ... }:
let
    secret_paths = [
        "password"
        "acme"
        "matrix/turn/username"
        "matrix/turn/credential"
        "matrix/matrix-authentication/secret"
        "matrix/matrix-authentication/config.yaml"
    ];
in 
{
    environment.systemPackages = [
        pkgs.sops
        pkgs.ssh-to-age
        pkgs.age
    ];

    sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        age.sshKeyPaths = [ "/persistent/ssh/id_ed25519" ];

        secrets = builtins.listToAttrs (builtins.map (path: {name = path; value = {neededForUsers = true;};}) secret_paths);
    };
}
