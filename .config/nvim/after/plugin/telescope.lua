local builtin = require("telescope.builtin")

require("telescope").setup({
	defaults = {
		layout_strategy = "horizontal",
		layout_config = {
			height = 400,
			width = 400,
			preview_cutoff = 80,
		},
		borderchars = { "", "", "", "", "", "", "", "" },
	},
})

vim.keymap.set("n", "<leader>f", function()
	builtin.find_files({ hidden = true })
end, { desc = "Telescope find files" })

vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Telescope find files tracked by git" })
vim.keymap.set("n", "<leader>ps", function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search keymaps" })
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search help tags" })
