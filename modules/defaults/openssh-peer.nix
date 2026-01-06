{ config, ... }:
{
    secrets.secrets = {
        "ssh/peer.pub" = {
            neededForUsers = true;
        };
        "ssh/peer.priv" = {
            neededForUsers = true;
        };
    };

    users.users.root.openssh.authorizedKeys.keyFiles = [ config.sops.secrets."ssh/peer.pub".path ];
    users.users.itec.openssh.authorizedKeys.keyFiles = [ config.sops.secrets."ssh/peer.pub".path ];
}
