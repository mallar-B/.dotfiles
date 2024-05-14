return {
  {
    "williamboman/mason.nvim",
    lazy = false,
      config = function()
        require("mason").setup()
      end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    config = function()
      require("mason-lspconfig").setup({
        ensure_install = { "tsserver", "lua_ls" }
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      local lspconfig = require("lspconfig")
      lspconfig.tsserver.setup({
        capabilities = capabilities
      })
      lspconfig.lua_ls.setup({
        capabilities = capabilities
      })
      vim.keymap.set('n', 'H', vim.lsp.buf.hover, {})
      vim.keymap.set({ 'n', 'v' }, 'A', vim.lsp.buf.code_action, {})
    end
  }
}
