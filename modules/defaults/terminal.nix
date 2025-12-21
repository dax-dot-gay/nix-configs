{ pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        btop
        ghostty.terminfo
        git
        neovim
        nerd-fonts.fira-code
        fastfetch
    ];

    programs.starship = {
        enable = true;
        presets = [ "nerd-font-symbols" ];
    };

    programs.zsh = {
        enable = true;
        interactiveShellInit = ''
            fastfetch --config examples/8.jsonc
        '';
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        autosuggestions = {
            enable = true;
            strategy = [
                "history"
                "completion"
            ];
        };
    };

    users.users.itec.shell = pkgs.zsh;
    users.users.root.shell = pkgs.zsh;
}
