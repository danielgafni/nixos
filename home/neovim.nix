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
    plugins.fugitive.enable = true;
    plugins.chadtree.enable = true;
    plugins.bufferline.enable = true;

    plugins.lsp = {
      enable = true;
      servers = {
        nixd.enable = true;
        ruff.enable = true;
        pyright.enable = true;
        yamlls.enable = true;
        jsonls.enable = true;
        helm-ls.enable = true;
        dockerls.enable = true;
        docker-compose-language-service.enable = true;
        terraformls.enable = true;
      };
    };
    plugins.lsp-format.enable = true;
    plugins.helm.enable = true;

    opts = {
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers

      shiftwidth = 4;
    };

    keymaps = [
      {
        key = "<leader>t";
        action = "<cmd>:CHADopen<CR>";
      }
    ];
  };
}
