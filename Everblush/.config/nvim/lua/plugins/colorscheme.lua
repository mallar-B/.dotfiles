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
        vim.cmd [[
          highlight CursorLine guibg=#22292b
          highlight Visual guibg= #232a2d
          highlight SignColumn guifg=#b3b9b8
          highlight LineNr guifg=#777777 guibg=#192022
          highlight CursorLineNr guifg=#e57474 gui=bold
          highlight LspReferenceText guibg=#192022 guifg=none
          " highlight LspReferenceRead  guibg=#2a4030
          " highlight LspReferenceWrite guibg=#40302a gui=bold
        ]],
        -- everblush colorscheme
        -- {
        --   fg = '#dadada',
        --   bg = '#181f21',
        --   black = '#22292b',
        --   darkbg = '#151b1d',
        --   red = '#e06e6e',
        --   green = '#8ccf7e',
        --   yellow = '#e5c76b',
        --   blue = '#67b0e8',
        --   magenta = '#c47fd5',
        --   cyan = '#6cd0ca',
        --   white = '#b3b9b8',
        -- },
      }
    end,
  },
}
