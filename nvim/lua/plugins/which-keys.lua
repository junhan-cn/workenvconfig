local wk = require("which-key")

wk.add({
	-- lsp keymap
	{ "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "go to definition" },
	{ "gr", "<cmd>lua vim.lsp.buf.references()<cr>", desc = "go to reference" },
	{ "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", desc = "go to implementation" },
	{ "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>",  desc = "go to declaration" },

	-- telsescop
	{"<leader>f", "<cmd>Telescope find_files<cr>", desc = "search files (include submodules)"},
	{"<leader>g","<cmd>Telescope live_grep<cr>", desc = "live grep"},
	{ "gs", "<cmd>Telescope grep_string<cr>",  desc = "grep string" },

	-- quickfix windows
	{"gc", "<cmd>cclose<cr>", desc = "close quickfix windows"},

	--sidbar
	{"<F3>", "<cmd>NvimTreeToggle<cr>", desc = "close sidbar"}


})
