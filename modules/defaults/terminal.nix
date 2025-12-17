{ pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        btop
        ghostty.terminfo
        git
        neovim
        nerd-fonts.fira-code
        hyfetch
        fastfetch
    ];

    programs.starship = {
        enable = true;
        presets = [ "nerd-font-symbols" ];
    };

    programs.zsh = {
        enable = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        autosuggestions = {
            enable = true;
            strategy = [
                "history"
                "completion"
            ];
        };
        #shellInit = "hyfetch --distro=NixOS_small --args=\"--config examples/8.jsonc\" --preset=transgender --mode=rgb --backend=fastfetch --c-set-l=0.65";
    };

    users.users.itec.shell = pkgs.zsh;
    users.users.root.shell = pkgs.zsh;
}
