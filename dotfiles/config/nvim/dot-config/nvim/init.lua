vim.g.mapleader = " ";
vim.o.timeout = true;
vim.o.timeoutlen = 300;
vim.o.background = "dark";
vim.o.list = true;
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.autoindent = true
vim.o.linebreak = true
vim.o.relativenumber = true
vim.g.better_whitespace_enabled = 1
vim.g.better_whitespace_filetypes_blacklist = {}

require("which-key").setup();

require("nvim-treesitter.configs").setup({
  auto_install = false,
  highlight = {
    enable = true,
  },
 });

local lsp_zero = require("lsp-zero")
local lsp_attach = function(client, bufnr)
  lsp_zero.default_keymaps({
    buffer = bufnr,
    preserve_mappings = false,
  });
end;
lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities()
});

require("lspconfig").nixd.setup({});
require("lspconfig").pylyzer.setup({});
require("lspconfig").elixirls.setup({
  cmd = { "elixir-ls" }
});
-- require("lspconfig").lexical.setup({
--   cmd = { "lexical" }
-- });

local cmp = require('cmp');
cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
    {name = 'buffer'},
  },
  snippet = {
    expand = function(args)
      -- You need Neovim v0.10 to use vim.snippet
      vim.snippet.expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({}),
});

local telescope = require('telescope')
telescope.setup {
  pickers = {
    find_files = {
      -- find_command = { 'rg', '--files', '--iglob', '!.git/objects', '--hidden'}
    },
    live_grep = { hidden = true }
  }
}
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fF', function() builtin.find_files({hidden=true}) end, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fG', function() builtin.live_grep({hidden=true}) end, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

require("autoclose").setup({
  options = {
    disabled_filetypes = {"markdown", "text"}
  }
});
require("better_escape").setup()
require("lualine").setup();
require("modus-themes").setup({
  variant = "default",
  -- variant = "tinted",
  -- variant = "deuteranopia",
  -- variant = "tritanopia",
  transparent = "true",
});
vim.cmd([[colorscheme modus]])

