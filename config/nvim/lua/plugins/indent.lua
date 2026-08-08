return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
    config = function()
      vim.cmd [[
      highlight IndentBlanklineChar guifg=#555555 gui=nocombine
      highlight IndentBlanklineScope guifg=#888888 gui=nocombine
      ]]

      -- Setup indent-blankline with single indent and scope color
      require('ibl').setup {
        indent = {
          char = '│',
          highlight = 'IndentBlanklineChar',
        },
        scope = {
          enabled = true,
          show_start = false,
          show_end = false,
          highlight = 'IndentBlanklineScope',
        },
      }
    end,
  },
  -- {
  --   'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically
  -- },
}
