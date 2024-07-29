function Request_signature_help()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, 'textDocument/hover', params, function(err, result, context, config)
    if err then
      print 'err'
      return
    end
    if result then
      print(result.contents.value) -- Print the type of the result
      vim.api.nvim_open_win(0, false, { relative = 'win', row = 3, col = 3, width = 12, height = 3 })
    end
  end)
end

vim.keymap.set('n', '<C-m>', Request_signature_help)
