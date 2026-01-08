{
    config,
    lib,
    pkgs,
    ...
}:
with lib;
let
    cfg = config.lesbos.system_users;
in
{
    options = {
        lesbos.system_users = mkOption {
            type = types.attrsOf types.submodule (
                { config, ... }:
                {
                    options = {
                        group = mkOption {
                            type = types.str;
                            default = config._module.args.name;
                            description = "Override group name (defaults to username)";
                        };
                        home = mkOption {
                            type = types.str;
                            default = "/home/system-${config._module.args.name}";
                            description = "User homedir";
                        };
                        extra_groups = mkOption {
                            type = types.listOf types.str;
                            default = [ ];
                            description = "Extra groups to add this user to";
                        };
                    };
                }
            );
        };
    };

    config = {
        users.users = mapAttrs (name: value: {
            isSystemUser = true;
            shell = pkgs.zsh;
            home = value.home;
            group = value.group;
            extraGroups = value.extra_groups;
        }) cfg;
        users.groups = mapAttrs' (name: value: {
            name = value.group;
            value = { };
        }) cfg;
    };
}
