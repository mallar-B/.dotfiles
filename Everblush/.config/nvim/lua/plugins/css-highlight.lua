return {
  -- {
  --   'brenoprata10/nvim-highlight-colors',
  --   config = function()
  --     vim.opt.termguicolors = true
  --     require('nvim-highlight-colors').setup {}
  --   end,
  -- },
  {'norcalli/nvim-colorizer.lua',
    config = function ()
      require 'colorizer'.setup{
        '*',
        DEFAULT_OPTIONS = {
        RGB      = true;         -- #RGB hex codes
        RRGGBB   = true;         -- #RRGGBB hex codes
        names    = true;         -- "Name" codes like Blue
        RRGGBBAA = true;        -- #RRGGBBAA hex codes
        rgb_fn   = true;        -- CSS rgb() and rgba() functions
        hsl_fn   = true;        -- CSS hsl() and hsla() functions
        css      = true;        -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn   = true;        -- Enable all CSS *functions*: rgb_fn, hsl_fn
        -- Available modes: foreground, background
        mode     = 'background'; -- Set the display mode.
  }
      }
    end

  },
  {
    'ziontee113/color-picker.nvim',
    config = function()
      require('color-picker').setup {}
    end,
  },
}
