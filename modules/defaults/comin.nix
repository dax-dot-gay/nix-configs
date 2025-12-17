{ repository, hostname, ... }:
{
    services.comin = {
        enable = true;
        remotes = [
            {
                name = "origin";
                url = "${repository}";
                branches.main.name = "main";
            }
        ];

        hostname = "${hostname}";
    };
}
