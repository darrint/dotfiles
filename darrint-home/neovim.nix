{ pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    globals = {
      mapleader = " ";
      better_whitespace_enabled = 1;
      better_whitespace_filetypes_blacklist = {};
    };
    opts = {
      timeout = true;
      timeoutlen = 300;
      background = "dark";
      list = true;
      expandtab = true;
      softtabstop = 2;
      shiftwidth = 2;
      autoindent = true;
      linebreak = true;
      relativenumber = true;
      signcolumn = "yes";
    };

    plugins = {
      better-escape.enable = true;
      vim-surround.enable = true;
      gitgutter.enable = true;
      web-devicons.enable = true;
      which-key.enable = true;
      lualine.enable = true;
      transparent.enable = true;
      telescope = {
        enable = true;
	keymaps = {
	  "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
          # vim.keymap.set('n', '<leader>fF', function() builtin.find_files({hidden=true}) end, {})
	  # vim.keymap.set('n', '<leader>fG', function() builtin.live_grep({hidden=true}) end, {})
	};
      };
      treesitter = {
        enable = true;

        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
          json
          lua
          make
          markdown
          nix
          regex
          toml
          vim
          vimdoc
          xml
          yaml

	  elixir
          eex
	  heex
        ];

       folding = false;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      alpha = {
        enable = true;
	theme = "dashboard";
      };

      lsp = {
        enable = true;
	servers = {
          ts_ls.enable = true; # TS/JS
          cssls.enable = true; # CSS
          tailwindcss.enable = true; # TailwindCSS
          html.enable = true; # HTML
          astro.enable = true; # AstroJS
          phpactor.enable = true; # PHP
          svelte.enable = false; # Svelte
          vuels.enable = false; # Vue
          pyright.enable = true; # Python
          marksman.enable = true; # Markdown
          nil_ls.enable = true; # Nix
          dockerls.enable = true; # Docker
          bashls.enable = true; # Bash
          clangd.enable = true; # C/C++
          csharp_ls.enable = true; # C#
          yamlls.enable = true; # YAML
	  elixirls.enable = true;

	  lua_ls = {
	    enable = true;
	    settings.diagnostics.globals = [
	      "vim" "require"
	    ];
	  };
	};
      };

      cmp-emoji.enable = true;
      cmp = {
        enable = true;
	settings = {
	  sources = [
	    {name = "nvim_lsp";}
	    {name = "emoji";}
	    {name = "buffer";}
	    {name = "path";}
	    # {name = "luasnip";}
	  ];
	};
      };
    };

    keymaps = [
      {
        key = "K";
	action = "<cmd>lua vim.lsp.buf.hover()<cr>";
	mode = "n";
      }
      {
        key = "gd";
	action = "<cmd>lua vim.lsp.buf.definition()<cr>";
	mode = "n";
      }
      {
        key = "gD";
	action = "<cmd>lua vim.lsp.buf.declaration()<cr>";
	mode = "n";
      }
      {
        key = "gi";
	action = "<cmd>lua vim.lsp.buf.implementation()<cr>";
	mode = "n";
      }
      {
        key = "go";
	action = "<cmd>lua vim.lsp.buf.type_definition()<cr>";
	mode = "n";
      }
      {
        key = "gr";
	action = "<cmd>lua vim.lsp.buf.references()<cr>";
	mode = "n";
      }
      {
        key = "gs";
	action = "<cmd>lua vim.lsp.buf.signature_help()<cr>";
	mode = "n";
      }
      {
        key = "<F2>";
	action = "<cmd>lua vim.lsp.buf.rename()<cr>";
	mode = "n";
      }
      {
        key = "<F3>";
	action = "<cmd>lua vim.lsp.buf.format({async = true})<cr>";
	mode = ["n" "x"];
      }
      {
        key = "<F4>";
	action = "<cmd>lua vim.lsp.buf.code_action()<cr>";
	mode = "n";
      }

      {
        key = "H";
	action = ":nohlsearch<cr>";
	mode = "n";
      }
    ];

    colorschemes.modus = {
      enable = true;
    };
  };

}

