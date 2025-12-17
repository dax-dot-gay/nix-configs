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
            "acme/username".neededForUsers = true;
            "acme/key".neededForUsers = true;
        };

        templates."namecheap.env".content = ''
            NAMECHEAP_API_USER=${config.sops.placeholder."acme/username"}
            NAMECHEAP_API_KEY=${config.sops.placeholder."acme/key"}
        '';
        templates."namecheap.env".neededForUsers = true;
    };
}
