{
    config,
    daxlib,
    lib,
    pkgs,
    ...
}:
with lib;
let
    hosts = daxlib.hosts;
    cfg = config.lesbos.volumes;
    volume_options = types.submodule {
        options = {
            path = mkOption {
                type = types.path;
                description = "The path on the remote within the base directory to mount";
                default = "/";
            };
            remote = mkOption {
                description = "Configuration of remote";
                type = types.submodule {
                    options = {
                        name = mkOption {
                            type = types.str;
                            description = "Name of this remote";
                            default = "infra-nfs";
                        };
                        host = mkOption {
                            type = types.str;
                            description = "IP/hostname of the remote peer";
                            default = "${hosts.ip "infra-nfs"}";
                        };
                        port = mkOption {
                            type = types.number;
                            description = "SFTP port to connect to on the remote peer";
                            default = 22;
                        };
                        base_path = mkOption {
                            type = types.path;
                            description = "Base path on this remote";
                            default = "/shared";
                        };
                        user = mkOption {
                            type = types.str;
                            description = "Remote user to mount as";
                            default = "root";
                        };
                        private_keyfile = mkOption {
                            type = types.path;
                            description = "Path to SFTP private key";
                            default = config.sops.secrets."ssh/peer.priv".path;
                        };
                        public_keyfile = mkOption {
                            type = types.path;
                            description = "Path to SFTP public key";
                            default = config.sops.secrets."ssh/pub.priv".path;
                        };
                    };
                };
                default = { };
            };
            user = mkOption {
                type = types.str;
                description = "User to rewrite ownership to locally";
                default = "root";
            };
            group = mkOption {
                type = types.str;
                description = "Group to rewrite ownership to locally";
                default = "root";
            };
            umask = mkOption {
                type = types.strMatching "^[0-7]++$";
                description = "Umask to rewrite filesystem to locally";
                default = "027";
            };
            mode = mkOption {
                type = types.strMatching "^[0-7]++$";
                description = "File mode of the volume directory when created";
                default = "750";
            };
        };
    };
in
{
    options = {
        lesbos.volumes = mkOption {
            type = types.attrsOf volume_options;
            description = ''
                Mapping of <local path> = {...} to mount.
                By default, connects to infra-nfs and mounts under /shared.
            '';
            default = { };
            example = {
                "/var/lib/postgres" = {
                    path = "/systems/infra/postgres";
                    owner = "postgres";
                    group = "postgres";
                };
            };
        };
    };

    config =
        let
            remotes = lib.fold (
                current: acc: if (lib.hasAttr current.remote.name acc) then acc else acc // {"${current.remote.name}" = current.remote;}
            ) { } (lib.attrValues cfg);
        in
        {
            environment.systemPackages = [ pkgs.rclone ];
            environment.etc."rclone-volumes.conf".text = lib.generators.toJSON {} remotes;
        };
}
