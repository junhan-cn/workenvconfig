require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

require("mason-lspconfig").setup({
	-- A list of servers to automatically install if they're not already installed.
	ensure_installed = {"clangd","rust_analyzer"},
})



local lspconfig = require("lspconfig")


lspconfig.clangd.setup({
	cmd = {'clangd', '--background-index', '--clang-tidy', '--log=verbose'},
})

lspconfig.rust_analyzer.setup({
	 cmd = {"rust-analyzer"};
	     filetypes = {"rust"};
})

