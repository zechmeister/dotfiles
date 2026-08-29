local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		scss = { "prettier" },
		terraform = { "terraform_fmt" },
		tf = { "terraform_fmt" },
	},
})

local format = function()
	conform.format({ lsp_format = "fallback", timeout_ms = 500 })
end
vim.keymap.set({ "n", "v" }, "<leader>lf", format, { desc = "Format with conform or LSP" })
vim.api.nvim_create_autocmd("BufWritePre", { callback = format })
