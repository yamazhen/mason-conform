local config = require("mason-conform.config")
local registry = require("mason-conform.registry")
local resolve = require("mason-conform.resolve")

local M = {}

local owned = {}

function M.apply()
	local ok, conform = pcall(require, "conform")
	if not ok then
		return
	end
	local resolved = resolve.formatters_by_ft()

	for ft in pairs(owned) do
		if resolved[ft] == nil then
			conform.formatters_by_ft[ft] = nil
			owned[ft] = nil
		end
	end

	for ft, formatters in pairs(resolved) do
		if owned[ft] or conform.formatters_by_ft[ft] == nil then
			conform.formatters_by_ft[ft] = formatters
			owned[ft] = true
		end
	end
end

local function refresh()
	resolve.invalidate()
	M.apply()
end

function M.setup(opts)
	config.set(opts)
	resolve.invalidate()

	vim.api.nvim_create_autocmd("FileType", {
		once = true,
		group = vim.api.nvim_create_augroup("mason-conform", { clear = true }),
		callback = function()
			registry.on_change(refresh)
			M.apply()
		end,
	})
end

M.formatters_by_ft = resolve.formatters_by_ft
M.invalidate = resolve.invalidate

return M
