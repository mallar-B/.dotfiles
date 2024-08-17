-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

require("lushwal").add_reload_hook(hook)

vim.cmd([[colorscheme lushwal]])

-- require('plugins.transparent')
