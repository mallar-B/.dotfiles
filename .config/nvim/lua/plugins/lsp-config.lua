return {
  {
    "williamboman/mason.nvim",
      config = function()
        require("mason").setup()
      end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_install = { "tsserver" }
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.tsserver.setup({})
      vim.keymap.set('n', 'H', vim.lsp.buf.hover, {})
      vim.keymap.set({ 'n', 'v' }, 'A', vim.lsp.buf.code_action, {})
    end
  }
}
