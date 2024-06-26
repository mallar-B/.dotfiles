vim.cmd("set expandtab")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set tabstop=2")
vim.g.mapleader = " "

-- save
vim.keymap.set({'n', 'v', 'i'}, '<C-s>',
  function()
    local curr_mode = vim.fn.mode()
    if curr_mode == 'n' or curr_mode == 'v' or curr_mode == 'i' then
      vim.cmd(':w')
    end
  end,
  { noremap = true, silent = true}
  )

-- save and quit  
vim.keymap.set({'n', 'v', 'i'}, '<C-x>',
  function()
    local curr_mode = vim.fn.mode()
    if curr_mode == 'n' or curr_mode == 'v' or curr_mode == 'i' then
      vim.cmd(':wq')
    end
  end,
  { noremap = true, silent = true}
  )


