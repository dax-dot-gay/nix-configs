{ config, ... }:
{
    services.jellarr = {
        enable = true;
        config = {
            base_url = "http://0.0.0.0:8096";
        };
    };
}
