{pkgs, ...}: {
  programs.neovim.catppuccin.enable = false; # don't use catppuccin-nix, use catppuccin from nixvim instead (see below)

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

    plugins = {
      nix.enable = true;

      copilot-vim.enable = true;

      cmp.enable = true;
      cmp-path.enable = true;
      cmp-buffer.enable = true;
      cmp-cmdline.enable = true;

      noice.enable = true;
      lightline.enable = true;
      treesitter.enable = true;
      fugitive.enable = true;
      chadtree.enable = true;
      bufferline.enable = true;

      lsp = {
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
      lsp-format.enable = true;
      helm.enable = true;
    };

    opts = {
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers

      shiftwidth = 4;
    };

    keymaps = [
      {
        key = "<leader>t";
        action = "<cmd>CHADopen<CR>";
      }
    ];
  };
}
