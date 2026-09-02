local config = require("mason-conform.config")
local M = {}

function M.from_language(lang)
	local cfg, key = config.options, lang:lower()
	local fts = vim.deepcopy(cfg.aliases[key] or { key })
	vim.list_extend(fts, cfg.expand[key] or {})
	return fts
end

return M
