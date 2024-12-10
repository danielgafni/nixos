{pkgs, ...}: {
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.zed-mono
    nerd-fonts.symbols-only

    recursive # for eww
    #fira-code
    #fira-code-symbols
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    cabin
  ];
}
