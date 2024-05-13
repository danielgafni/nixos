{pkgs, ...}: {
  programs.nixvim = {
    enable = true;
    clipboard.providers.wl-copy.enable = true;
    colorschemes.catppuccin.enable = true;
    colorschemes.catppuccin.settings = {
      flavour = "mocha";
      integrations = {
        cmp = true;
        gitsigns = true;
        mini = true;
        notify = true;
        nvimtree = true;
        treesitter = true;
      };
    };

    plugins.nix.enable = true;

    plugins.copilot-vim.enable = true;

    plugins.cmp.enable = true;
    plugins.cmp-path.enable = true;
    plugins.cmp-buffer.enable = true;
    plugins.cmp-cmdline.enable = true;

    plugins.noice.enable = true;
    plugins.lightline.enable = true;
    plugins.treesitter.enable = true;

    plugins.lsp.enable = true;
    plugins.lsp-format.enable = true;

    opts = {
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers

      shiftwidth = 4;
    };
  };
}
