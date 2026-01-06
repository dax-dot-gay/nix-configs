{ ... }:
{
    secrets.secrets = {
        "ssh/peer.pub" = {
            neededForUsers = true;
        };
        "ssh/peer.priv" = {
            neededForUsers = true;
        };
    };

    users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFsoY66q/ej1AfjYuJ1d2t7RWdKizRi2TCJ73vEP0iq root@lesbos.peer" ];
    users.users.itec.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFsoY66q/ej1AfjYuJ1d2t7RWdKizRi2TCJ73vEP0iq root@lesbos.peer" ];
}
