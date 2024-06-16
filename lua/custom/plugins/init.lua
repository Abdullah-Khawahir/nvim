-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

return {
  {
    'ray-x/lsp_signature.nvim',
    event = 'VeryLazy',
    opts = {
      bind = true, -- Mandatory for config to take effect
      floating_window = true, -- Enable floating window
      hint_enable = true, -- Enable virtual text hint
      hint_prefix = '🐼 ', -- Prefix for the hint
      handler_opts = {
        border = 'rounded', -- Border style: "single", "double", "rounded", "shadow", or "none"
      },
      -- floating_window_above_cur_line = true, -- Keep window below cursor
      -- floating_window_off_x = -16, -- Offset in the X direction
      -- floating_window_off_y = 80, -- Offset in the Y direction
      -- max_height = 5, -- Max height of the floating window
      -- max_width = 80, -- Max width of the floating window
      transparency = 10, -- Floating window transparency from 0-100 (less is more transparent)
      always_trigger = false, -- Show signature help regardless of typing
      toggle_key = '<C-k>', -- Key to toggle signature help window
    },
    config = function(_, opts)
      vim.api.nvim_set_keymap('n', '<leader>ts', '<cmd>lua require("lsp_signature").toggle_float_win()<CR>', { noremap = true, silent = true })
      require('lsp_signature').setup(opts)
    end,
  },
}
