{ lib, config, ... }:
with lib;
let
    cfg = config.ensureDirs;
    users = config.users.users;
in
{
    options.ensureDirs = mkOption {
        type = types.attrsOf (
            types.submodule (
                { config, ... }:
                {
                    options = {
                        path = mkOption {
                            type = types.path;
                            default = config._module.args.name;
                            description = ''
                                Path of the desired directory
                            '';
                        };

                        mode = mkOption {
                            type = types.str;
                            default = "0777";
                            description = ''
                                Permissions of this directory
                            '';
                        };

                        owner = mkOption {
                            type = types.str;
                            default = "root";
                            description = ''
                                Sets the owner of this directory
                            '';
                        };
                        group = mkOption {
                            type = types.str;
                            default = if config.owner != null then users.${config.owner}.group else "root";
                            defaultText = literalMD "{option}`config.users.users.\${owner}.group`";
                            description = ''
                                Group of the directory
                            '';
                        };
                    };
                }
            )
        );
    };

    config = {
        systemd.tmpfiles.rules = builtins.map (
            value: "d ${value.path} ${value.mode} ${value.owner} ${value.group} 99999y"
        ) (lib.attrValues cfg);
    };
}
