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
                type = types.str;
                description = "The path on the remote within the base directory to mount";
                default = "/";
            };
            subpaths = mkOption {
                type = types.listOf types.str;
                description = "Paths within this folder to create";
                default = [ ];
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
                            type = types.str;
                            description = "Base path on this remote";
                            default = "/export/shared";
                        };
                        user = mkOption {
                            type = types.str;
                            description = "Remote user to mount as";
                            default = "root";
                        };
                        keyfile = mkOption {
                            type = types.str;
                            description = "Path to SFTP private key";
                            default = toString config.sops.secrets."ssh/peer.priv".path;
                        };
                    };
                };
                default = { };
            };
            owner = mkOption {
                type = types.str;
                description = "User to rewrite ownership to locally";
                default = "root";
            };
            group = mkOption {
                type = types.str;
                description = "Group to rewrite ownership to locally";
                default = "root";
            };
            mode = mkOption {
                type = types.strMatching "^[0-7]++$";
                description = "File mode of the volume directory and all internal files";
                default = "750";
            };
            umask = mkOption {
                type = types.strMatching "^[0-7]++$";
                description = "Umask of the volume directory and all internal files";
                default = "000";
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
                current: acc:
                if (lib.hasAttr current.remote.name acc) then
                    acc
                else
                    acc // { "${current.remote.name}" = current.remote; }
            ) { } (lib.attrValues cfg);
        in
        {
            environment.systemPackages = [ pkgs.rclone ];
            environment.etc."rclone-volumes.conf".text = concatStringsSep "\n" (
                mapAttrsToList (name: value: ''
                    [${name}]
                    type = sftp
                    host = ${value.host}
                    port = ${toString value.port}
                    user = ${value.user}
                    key_file = ${value.keyfile}

                '') remotes
            );
            systemd.services = mapAttrs' (name: value: {
                name = "volume-${replaceStrings [ "/" ] [ "-" ] (removePrefix "/" name)}";
                value = {
                    preStart = ''
                        cp /etc/static/rclone-volumes.conf /run/rclone-volumes.conf
                        mkdir -p ${name}
                        chmod -R ${value.mode} ${name}
                        chown -R ${value.owner}:${value.group} ${name}

                        ssh -i ${value.remote.keyfile} -p ${toString value.remote.port} ${value.remote.user}@${value.remote.host} mkdir -p ${removeSuffix "/" value.remote.base_path}/${removePrefix "/" value.path}
                    '';
                    script = ''
                        rclone mount ${value.remote.name}:${removeSuffix "/" value.remote.base_path}/${removePrefix "/" value.path} ${name} --daemon --allow-other --vfs-cache-mode writes --cache-dir /var/cache/rclone --config /run/rclone-volumes.conf --uid $(id -u ${value.owner}) --gid $(id -g ${value.group}) --umask ${value.umask} --temp-dir /tmp -vv --log-file /run/rclone.volumes.log --allow-non-empty

                        ${concatStringsSep "\n" (map (subpath: "mkdir -p ${removeSuffix "/" name}/${removePrefix "/" subpath}") value.subpaths)}
                        chmod -R ${value.mode} ${name}

                        sleep infinity
                    '';
                    reload = ''
                        umount ${name}
                    '';
                    preStop = ''
                        umount ${name}
                    '';
                    wantedBy = [ "multi-user.target" "systemd-tmpfiles-setup.service" "systemd-tmpfiles-resetup.service" ];
                    environment = {
                        TMPDIR = "/run";
                        RCLONE_TEMP_DIR = "/run";
                        HOME = "/run";
                        XDG_CONFIG_HOME = "/run";
                        RCLONE_CONFIG_DIR = "/run";
                    };
                    path = [
                        pkgs.coreutils-full
                        pkgs.getent
                        pkgs.rclone
                        pkgs.mount
                        pkgs.umount
                        pkgs.openssh
                        pkgs.bash
                    ];
                };
            }) cfg;
        };
}
