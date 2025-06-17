return {
  {
    'Everblush/nvim',
    name = 'everblush',
    lazy = false,
    priority = 1000,
    config = function()
      require('everblush').setup {
        -- Default options
        override = {},
        transparent_background = false,

        -- Set contrast for nvim-tree highlights
        nvim_tree = {
          contrast = true,
        },
        vim.cmd.colorscheme 'everblush',
      }
    end,
  },
}
