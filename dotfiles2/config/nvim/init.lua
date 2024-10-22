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

-- local lsp_zero = require("lsp-zero")
-- local lsp_attach = function(client, bufnr)
--   lsp_zero.default_keymaps({
--     buffer = bufnr,
--     preserve_mappings = false,
--   });
-- end;
-- lsp_zero.extend_lspconfig({
--   sign_text = true,
--   lsp_attach = lsp_attach,
--   capabilities = require('cmp_nvim_lsp').default_capabilities()
-- });

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local opts = {buffer = event.buf}
    print("lspattach")

    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  end,
})

local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

require("lspconfig").nixd.setup({});
require("lspconfig").pylyzer.setup({});
require("lspconfig").elixirls.setup({
  cmd = { "elixir-ls" }
});
require("lspconfig").lua_ls.setup({
  settings = {
    Lua = {
      diagnostics = {
        globals = {
          'vim',
          'require'
        }
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true)
      }
    }
  }
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

