return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup {
        open_mapping = [[<C-/>]],
        direction = 'horizontal',

        vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' }),
        vim.keymap.set('n', '<C-t>', '<cmd>ToggleTermToggleAll<CR>', { desc = 'Toggle terminal' }),
      }
    end,
  },
}
