return {
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    opts = {
      enable_autocmd = false,
    },
  },

  {
    'numToStr/Comment.nvim',
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    config = function()
      local context_commentstring = require 'ts_context_commentstring.integrations.comment_nvim'

      require('Comment').setup {
        pre_hook = function(ctx)
          -- QML/KDL is not reliably resolved by ts-context-commentstring.
          if vim.bo.filetype == 'qml' or vim.bo.filetype == 'kdl' then
            return '// %s'
          end

          return context_commentstring.create_pre_hook()(ctx)
        end,
      }
    end,
  },

  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
}
