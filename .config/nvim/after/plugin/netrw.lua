vim.g.netrw_banner = 0

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
			vim.cmd.Explore()
		end
	end,
})
