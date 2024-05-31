{pkgs, ...}: {
  programs.bat = {
    enable = true;
    catppuccin.enable = true;
    config = {
      pager = "less -FR";
    };
    extraPackages = with pkgs.bat-extras; [batdiff batman batgrep batwatch];
  };
}
