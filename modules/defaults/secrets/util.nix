{
    config,
    lib,
    pkgs,
    hostname,
    ...
}:
with lib;
let
    cfg = config.secrets;
    users = config.users.users;

    secretDefinitionOptions = types.submodule (
        { config, ... }:
        {
            config = {
                sopsFile = mkOptionDefault cfg.defaultSopsFile;
            };
            options = {
                hosts = mkOption {
                    type = types.listOf types.singleLineStr;
                    default = [ ];
                    description = ''
                        List of hosts to supply this secret to. If none are provided, assumes all hosts.
                    '';
                };
                neededForUsers = mkOption {
                    type = types.bool;
                    default = false;
                    description = ''
                        Enabling this option causes the secret to be decrypted before users and groups are created.
                        This can be used to retrieve user's passwords from sops-nix.
                        Setting this option moves the secret to /run/secrets-for-users and disallows setting owner and group to anything else than root.
                    '';
                };
                owner = mkOption {
                    type = types.str;
                    default = "root";
                    description = ''
                        Sets the owner of this secret (defaults to root)
                    '';
                };
                group = mkOption {
                    type = types.nullOr types.str;
                    default = if config.owner != null then users.${config.owner}.group else null;
                    defaultText = literalMD "{option}`config.users.users.\${owner}.group`";
                    description = ''
                        Group of the file. Can only be set if gid is 0.
                    '';
                };
                sopsFile = mkOption {
                    type = types.path;
                    defaultText = literalExpression "\${sops.defaultSopsFile}";
                    description = ''
                        Sops file the secret is loaded from.
                    '';
                };
                name = mkOption {
                    type = types.str;
                    default = config._module.args.name;
                    description = ''
                        Name of the file used in /run/secrets
                    '';
                };
                key = mkOption {
                    type = types.str;
                    default = if cfg.defaultSopsKey != null then cfg.defaultSopsKey else config._module.args.name;
                    description = ''
                        Key used to lookup in the sops file.
                        No tested data structures are supported right now.
                        This option is ignored if format is binary.
                        "" means whole file.
                    '';
                };
                path = mkOption {
                    type = types.str;
                    default =
                        if config.neededForUsers then
                            "/run/secrets-for-users/${config.name}"
                        else
                            "/run/secrets/${config.name}";
                    defaultText = "/run/secrets-for-users/$name when neededForUsers is set, /run/secrets/$name when otherwise.";
                    description = ''
                        Path where secrets are symlinked to.
                        If the default is kept no symlink is created.
                    '';
                };
                format = mkOption {
                    type = types.enum [
                        "yaml"
                        "json"
                        "binary"
                        "dotenv"
                        "ini"
                    ];
                    default = cfg.defaultSopsFormat;
                    description = ''
                        File format used to decrypt the sops secret.
                        Binary files are written to the target file as is.
                    '';
                };
                mode = mkOption {
                    type = types.str;
                    default = "0400";
                    description = ''
                        Permissions mode of the in octal.
                    '';
                };
                sopsFileHash = mkOption {
                    type = types.str;
                    readOnly = true;
                    description = ''
                        Hash of the sops file, useful in <xref linkend="opt-systemd.services._name_.restartTriggers" />.
                    '';
                };
                restartUnits = mkOption {
                    type = types.listOf types.str;
                    default = [ ];
                    example = [ "sshd.service" ];
                    description = ''
                        Names of units that should be restarted when this secret changes.
                        This works the same way as <xref linkend="opt-systemd.services._name_.restartTriggers" />.
                    '';
                };
                reloadUnits = mkOption {
                    type = types.listOf types.str;
                    default = [ ];
                    example = [ "sshd.service" ];
                    description = ''
                        Names of units that should be reloaded when this secret changes.
                        This works the same way as <xref linkend="opt-systemd.services._name_.reloadTriggers" />.
                    '';
                };
            };
        }
    );
in
{
    options.secrets = {
        enable = mkEnableOption "Per-system secrets";
        secrets = mkOption {
            type = types.attrsOf secretDefinitionOptions;
            default = { };
            description = ''
                Sops secrets
            '';
        };
    };

    config = mkIf cfg.enable {
        sops = {
            defaultSopsFile = ../../../secrets/secrets.yaml;
            age.sshKeyPaths = [ "/persistent/ssh/id_ed25519" ];
            secrets = listToAttrs (
                mapAttrsToList (
                    name: value:
                    if ((length value.hosts) == 0) || (elem hostname value.hosts) then
                        {
                            name = name;
                            value = filterAttrs (n: _: n != "hosts") value;
                        }
                    else
                        null
                ) cfg.secrets
            );
        };
    };
}
