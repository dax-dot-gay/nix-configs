{ ... }:
{
    nix.settings = {
        sandbox = true;
        experimental-features = [
            "nix-command"
            "flakes"
        ];
        trusted-users = [
            "root"
            "itec"
        ];
    };
}
