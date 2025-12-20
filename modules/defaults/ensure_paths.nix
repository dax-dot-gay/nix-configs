{ lib, config, ... }:
with lib;
let
    cfgFolders = config.ensureFolders;
    cfgFiles = config.ensureFiles;
    users = config.users.users;
    folderDefinition = types.submodule (
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
    );
    fileDefinition = types.submodule (
        { config, ... }:
        {
            options = {
                path = mkOption {
                    type = types.path;
                    default = config._module.args.name;
                    description = ''
                        Path of the desired file
                    '';
                };

                mode = mkOption {
                    type = types.str;
                    default = "0777";
                    description = ''
                        Permissions of this file
                    '';
                };

                owner = mkOption {
                    type = types.str;
                    default = "root";
                    description = ''
                        Sets the owner of this file
                    '';
                };
                group = mkOption {
                    type = types.str;
                    default = if config.owner != null then users.${config.owner}.group else "root";
                    defaultText = literalMD "{option}`config.users.users.\${owner}.group`";
                    description = ''
                        Group of the file
                    '';
                };
                content = mkOption {
                    type = types.str;
                    default = "";
                    description = ''
                        Content to initialize this file with
                    '';
                };
            };
        }
    );
in
{
    options.ensureFolders = mkOption {
        type = types.attrsOf (types.submodule folderDefinition);
        description = "Folders to create";
    };

    options.ensureFiles = mkOption {
        type = types.attrsOf (types.submodule fileDefinition);
        description = "Files to create";
    };

    config = {
        systemd.tmpfiles.rules =
            (builtins.map (value: "d ${value.path} ${value.mode} ${value.owner} ${value.group} 99999y") (
                lib.attrValues cfgFolders
            ))
            ++ (builtins.map (
                value: "f ${value.path} ${value.mode} ${value.owner} ${value.group} 99999y ${value.content}"
            ) (lib.attrValues cfgFiles));

        ensureFolders = {};
        ensureFiles = {};
    };
}
