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
                            default = "/shared";
                        };
                        user = mkOption {
                            type = types.str;
                            description = "Remote user to mount as";
                            default = "root";
                        };
                        private_keyfile = mkOption {
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
                    key_file = ${value.private_keyfile}

                '') remotes
            );
            ensurePaths.folders = mapAttrs (name: value: {
                mode = value.mode;
                owner = value.owner;
                group = value.group;
            }) cfg;
            /*
              systemd.services = mapAttrs (name: value: {
                  device = "${value.remote.name}:${removeSuffix "/" value.remote.base_path}/${removePrefix "/" value.path}";
                  fsType = "rclone";
                  options = [
                      "nodev"
                      "nofail"
                      "exec"
                      "rw"
                      "allow_other"
                      "args2env"
                      "_netdev"
                      "vfs-cache-mode=writes"
                      "cache-dir=/var/rclone"
                      "config=/etc/rclone-volumes.conf"
                      "uid=${toString config.users.users.${value.owner}.uid}"
                      "gid=${toString config.users.groups.${value.group}.gid}"
                      "umask=${value.umask}"
                      "temp-dir=/run"
                  ];
              }) cfg;
            */
            systemd.services = mapAttrs' (name: value: {
                name = "volume-${replaceStrings [ "/" ] [ "-" ] (removePrefix "/" name)}";
                value = {
                    wants = [ "systemd-tmpfiles-setup.service" ];
                    script = ''
                        rclone mount ${value.remote.name}:${removeSuffix "/" value.remote.base_path}/${removePrefix "/" value.path} ${name} --allow-other --vfs-cache-mode writes --cache-dir /var/cache/rclone --config /etc/rclone-volumes.conf --uid ${
                            toString config.users.users.${value.owner}.uid
                        } --gid ${toString config.users.groups.${value.group}.gid} --umask ${value.umask} --temp-dir /tmp
                    '';
                    wantedBy = [ "multi-user.target" ];
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
                    ];
                };
            }) cfg;
        };
}
