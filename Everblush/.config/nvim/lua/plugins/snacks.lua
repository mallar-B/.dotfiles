return {
  {
    'folke/snacks.nvim',
    ---@type snacks.Config
    opts = {
      notifier = {},
    },
    config = function()
      vim.keymap.set('n', '<leader>xx', '<cmd>lua Snacks.notifier.hide()<cr>', { silent = true, noremap = true, desc = 'Hide notifications' })
    end,
  },
}
