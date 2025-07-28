return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("neo-tree").setup({
			filesystem = {
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitognored = false,
				},
			},
		})

		vim.keymap.set(
			"n",
			"<leader>ee",
			"<cmd>Neotree source=filesystem reveal=true position=current<CR>",
			{ desc = "Toggle file explorer" }
		)
	end,
}
