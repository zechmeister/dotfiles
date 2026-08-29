require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
	},
	signs_staged = {
		add = { text = "+" },
		change = { text = "~" },
	},
	numhl = true,
	current_line_blame = true,
	current_line_blame_opts = {
		delay = 2000,
	},
	on_attach = function(bufnr)
		local gitsigns = package.loaded.gitsigns

		vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
		vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { buffer = bufnr, desc = "Stage hunk" })
		vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })

		vim.keymap.set("n", "]c", gitsigns.next_hunk, { buffer = bufnr, desc = "Next hunk" })
		vim.keymap.set("n", "[c", gitsigns.prev_hunk, { buffer = bufnr, desc = "Prev hunk" })
	end,
})
