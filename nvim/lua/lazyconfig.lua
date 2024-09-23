-- plugin config file
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup({
	"nvim-lua/plenary.nvim",

	"nvim-treesitter/nvim-treesitter", build = ":TSUpdate",

	"nvim-telescope/telescope.nvim", tag = "0.1.8",

	--lsp plugins
	"williamboman/mason-lspconfig.nvim",
	"williamboman/mason.nvim",
	"neovim/nvim-lspconfig"

})