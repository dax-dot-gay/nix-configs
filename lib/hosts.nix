let
    mkHost = hostname: ip-ending: {
        hostname = "${hostname}.lsb";
        ip = "192.168.30.${builtins.toString ip-ending}";
    };
    hosts = {
        base-lxc = mkHost "base-lxc" 5;
        base-vm = mkHost "base-vm" 6;
    };
in
{
    getHost = hostname: hosts.${hostname};
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
