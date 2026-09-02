local config = require("mason-conform.config")
local M = {}

function M.from_package(pkg_name)
	local mapped = config.options.formatter_names[pkg_name]
	if type(mapped) == "string" then
		return { mapped }
	elseif type(mapped) == "table" then
		return mapped
	end
	return { (pkg_name:gsub("%-", "_")) }
end

function M.is_excluded(pkg_name, chain)
	for _, n in ipairs(config.options.exclude) do
		if n == pkg_name or vim.tbl_contains(chain, n) then
			return true
		end
	end
	return false
end

return M
