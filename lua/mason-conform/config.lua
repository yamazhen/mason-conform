local M = {}

M.defaults = {
	aliases = {
		["c#"] = { "cs" },
		["c++"] = { "cpp" },
		["objective-c"] = { "objc" },
		shell = { "sh" },
		latex = { "tex" },
		protobuf = { "proto" },
	},
	expand = {
		javascript = { "javascriptreact" },
		typescript = { "typescriptreact" },
		json = { "jsonc" },
		shell = { "bash", "zsh" },
	},
	formatter_names = { ruff = { "ruff_organize_imports", "ruff_format" } },
	exclude = { "rustywind", "ast_grep", "doctoc", "markdown_toc" },
	overrides = {},
	lsp_fallback = true,
}

M.options = vim.deepcopy(M.defaults)

function M.set(opts)
	M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
