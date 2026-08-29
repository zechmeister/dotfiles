vim.g.mapleader = " "

local map = vim.keymap.set

map("n", "<leader>t", vim.cmd.Ex, { desc = "Tree file explorer" })

map("n", "<leader>w", ":write<CR>")
map("n", "<leader>o", ":update<CR>:source<CR>", { desc = "Save & reload config" })

map({ "n", "v", "x" }, "<leader>y", '"+y')
map({ "n", "v", "x" }, "<leader>d", '"+d')

vim.keymap.set("n", "]q", ":cnext<CR>", { silent = true })
vim.keymap.set("n", "[q", ":cprev<CR>", { silent = true })
vim.keymap.set("n", "<leader>q", function()
	local quickfix_open = vim.iter(vim.fn.getwininfo()):any(function(win)
		return win.quickfix == 1
	end)

	vim.cmd(quickfix_open and "cclose" or "copen")
end, { desc = "Close quickfix list" })

map("n", "<leader>x", function()
	local line = vim.api.nvim_get_current_line()
	print(vim.fn.system(line))
end, { desc = "Execute current line in shell" })
