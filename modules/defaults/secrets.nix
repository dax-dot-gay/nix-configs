{ pkgs, config, ... }:
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
        };
    };
}
