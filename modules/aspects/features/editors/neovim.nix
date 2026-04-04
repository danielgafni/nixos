{den, ...}: {
  den.aspects.neovim = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.sessionVariables = {
        SUDO_EDITOR = "nvim";
        EDITOR = "nvim";
      };
      catppuccin.nvim.enable = false;
      programs.nixvim = {
        enable = true;
        defaultEditor = true;
        colorschemes.catppuccin = {
          enable = true;
          settings = {
            flavour = "mocha";
            transparent_background = true;
            integrations = {
              cmp = true;
              gitsigns = true;
              mini = true;
              notify = true;
              nvimtree = true;
              treesitter = true;
            };
          };
        };
        plugins = {
          nix.enable = true;
          copilot-vim = {
            enable = true;
            package = pkgs.vimPlugins.copilot-vim;
          };
          cmp.enable = true;
          cmp-path.enable = true;
          cmp-buffer.enable = true;
          cmp-cmdline.enable = true;
          gitsigns.enable = true;
          noice.enable = true;
          lualine.enable = true;
          treesitter = {
            enable = true;
            settings.highlight.enable = true;
          };
          fugitive.enable = true;
          chadtree.enable = true;
          bufferline.enable = true;
          mini = {
            enable = true;
            mockDevIcons = true;
            modules.icons = {};
          };
          lsp = {
            enable = true;
            servers = {
              nil_ls.enable = true;
              ruff.enable = true;
              pyright.enable = true;
              yamlls.enable = true;
              jsonls.enable = true;
              helm_ls.enable = true;
              dockerls.enable = true;
              docker_compose_language_service.enable = true;
              terraformls.enable = true;
            };
          };
          lsp-format.enable = true;
          helm.enable = true;
        };
        opts = {
          number = true;
          relativenumber = true;
          shiftwidth = 4;
        };
        keymaps = [
          {
            key = "<leader>t";
            action = "<cmd>CHADopen<CR>";
          }
        ];
      };
    };
  };
}
