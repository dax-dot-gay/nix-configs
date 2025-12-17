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
    services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
            PermitRootLogin = "yes";
            PasswordAuthentication = false;
        };
    };
    # Cache DNS lookups to improve performance
    services.resolved = {
        extraConfig = ''
            Cache=true
            CacheFromLocalhost=true
        '';
    };
    system.stateVersion = "25.11";
}
