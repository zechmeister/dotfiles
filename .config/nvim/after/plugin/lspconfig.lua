vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'LSP: Rename' })
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { desc = 'LSP: Go to definition' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'LSP: References' })
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'LSP: Go to Implementation' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'LSP: Hover Docs' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'LSP: Rename' })
vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'LSP: Code Action' })

vim.lsp.enable({ "lua_ls", "terraformls" })
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', ']d', vim.diagnostic.jump)

vim.diagnostic.config({
	virtual_text = true,
	signs = true
})
