return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require('neo-tree').setup ({
        filesystem = {
          filtered_items = {
            visible = true, 
            hide_dotfiles = false,
            hide_gitignored = true,
          }
        }
      })
      vim.keymap.set({ 'n', 'i', 'v' }, '<C-b>', function ()
       vim.cmd(':Neotree toggle') 
      end, {})
    end
  }
}

 
