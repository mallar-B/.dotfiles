return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts

    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'python' },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
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
        go = { 'gofmt' },
        html = { 'prettierd' },
        javascript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        json = { 'prettierd' },
        lua = { 'stylua' },
        markdown = { 'prettierd' },
        nix = { 'alejandra' },
        php = { 'pretty-php' },
        python = { 'black' },
        rust = { 'rustfmt' },
        sh = { 'shfmt' },
        typescript = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        yaml = { 'prettierd' },
      },
    },
  },
}
