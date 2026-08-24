return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,

    config = function()
      local treesitter = require 'nvim-treesitter'

      treesitter.setup()

      treesitter.install {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'python',
      }

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local language = vim.treesitter.language.get_lang(args.match)

          if language then
            pcall(vim.treesitter.start, args.buf, language)
          end

          if args.match ~= 'ruby' then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'ruby',
        callback = function()
          vim.cmd 'syntax enable'
        end,
      })
    end,
  },

  { -- Formatter
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>p',
        function()
          require('conform').format()
        end,
        mode = '',
        desc = '[P]rettify buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = nil,
      formatters_by_ft = {
        ['_'] = { 'trim_whitespace', 'trim_newlines', 'squeeze_blanks' },
        bash = { 'shfmt' },
        cpp = { 'clang-format' },
        go = { 'goimports' },
        html = { 'prettierd' },
        javascript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        json = { 'prettierd' },
        kdl = { 'kdlfmt' },
        lua = { 'stylua' },
        markdown = { 'prettierd' },
        nix = { 'alejandra' },
        php = { 'pretty-php' },
        python = { 'black' },
        qml = { 'qmlformat' },
        rust = { 'rustfmt' },
        sh = { 'shfmt' },
        typescript = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        yaml = { 'prettierd' },
      },
    },
  },
}
