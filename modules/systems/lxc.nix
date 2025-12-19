{
    modulesPath,
    ...
}:
{
    imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];
    proxmoxLXC = {
        manageNetwork = false;
        privileged = true;
    };
    services.fstrim.enable = false; # Let Proxmox host handle fstrim
    # Cache DNS lookups to improve performance
    services.resolved = {
        extraConfig = ''
            Cache=true
            CacheFromLocalhost=true
        '';
    };
}
