{ ... }:
{
    services.openssh = {
        enable = true;
        settings = {
            UseDns = true;
            PasswordAuthentication = false;
            PermitRootLogin = "prohibit-password";
        };
    };

    users.users.itec.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIyeYCBhJ36mU1+cXEz4wNhbvHZIJRE4MhPtwmDyvDx root@lesbos"
    ];
    users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIyeYCBhJ36mU1+cXEz4wNhbvHZIJRE4MhPtwmDyvDx root@lesbos"
    ];
}
