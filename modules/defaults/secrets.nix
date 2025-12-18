{ pkgs, config, ... }:
let
    secret_paths = [
        "password"
        "acme"
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
