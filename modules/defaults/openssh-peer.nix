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
}
