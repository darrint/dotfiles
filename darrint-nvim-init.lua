vim.g.mapleader = " ";
vim.o.timeout = true;
vim.o.timeoutlen = 300;
vim.o.background = "light";
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
lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr});
end);

require("lspconfig").nixd.setup({});
require("lspconfig").pylyzer.setup({});
require("lspconfig").elixirls.setup({
  cmd = { "elixir-ls" }
});
-- require("lspconfig").lexical.setup({
--   cmd = { "lexical" }
-- });

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

require("autoclose").setup({
  options = {
    disabled_filetypes = {"markdown", "text"}
  }
});
require("better_escape").setup()
require("lualine").setup();
vim.cmd([[colorscheme adwaita]])

