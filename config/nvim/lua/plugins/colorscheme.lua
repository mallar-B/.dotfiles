return {
  {
    'neanias/everforest-nvim',
    priority = 1000,
    config = function()
      require('everforest').setup {
        background = 'medium',
        transparent_background_level = 0,
      }
      vim.cmd.colorscheme 'everforest'
    end,
  },
}
