let
    mkHost = hostname: ip-ending: {
        hostname = "${hostname}.lsb";
        ip = "192.168.30.${builtins.toString ip-ending}";
    };
    hosts = {
        base-lxc = mkHost "base-lxc" 5;
        base-vm = mkHost "base-vm" 6;
        infra-nfs = mkHost "infra-nfs" 10;
        infra-nginx = mkHost "infra-nginx" 11;
        infra-authentik = mkHost "infra-authentik" 12;
        services-access = mkHost "services-access" 20;
        services-matrix = mkHost "services-matrix" 21;
        services-jellyfin = mkHost "services-jellyfin" 22;
        services-romm = mkHost "services-romm" 23;
        services-kavita = mkHost "services-kavita" 24;
        services-audiobookshelf = mkHost "services-audiobookshelf" 25;
        services-wizarr = mkHost "services-wizarr" 26;
        services-arr = mkHost "services-arr" 27;
        services-syncthing = mkHost "services-syncthing" 28;
    };
in
{
    getHost = hostname: hosts.${hostname};
    ip = hostname: hosts.${hostname}.ip;
    makeHosts =
        hostname:
        builtins.listToAttrs (
            builtins.map (
                name:
                if name == hostname then
                    {
                        name = "127.0.0.1";
                        value = [
                            "localhost"
                            hosts.${name}.hostname
                        ];
                    }
                else
                    {
                        name = hosts.${name}.ip;
                        value = [ hosts.${name}.hostname ];
                    }
            ) (builtins.attrNames hosts)
        );
}
