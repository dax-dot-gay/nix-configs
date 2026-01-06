{ ... }:
{
    services.openssh = {
        enable = true;
        settings = {
            UseDns = true;
            PasswordAuthentication = false;
            PermitRootLogin = "prohibit-password";
        };
        allowSFTP = true;
    };

    users.users.itec.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIyeYCBhJ36mU1+cXEz4wNhbvHZIJRE4MhPtwmDyvDx root@lesbos"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFsoY66q/ej1AfjYuJ1d2t7RWdKizRi2TCJ73vEP0iq root@lesbos.peer"
    ];
    users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIyeYCBhJ36mU1+cXEz4wNhbvHZIJRE4MhPtwmDyvDx root@lesbos"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFsoY66q/ej1AfjYuJ1d2t7RWdKizRi2TCJ73vEP0iq root@lesbos.peer"
    ];
}
