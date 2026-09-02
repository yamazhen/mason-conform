local config = require("mason-conform.config")
local registry = require("mason-conform.registry")
local filetype = require("mason-conform.filetype")
local formatter = require("mason-conform.formatter")

local M = {}
local cache = nil

function M.invalidate()
	cache = nil
end

function M.candidates()
	local by_ft, seen = {}, {}
	for _, pkg in ipairs(registry.installed_formatters()) do
		local chain = formatter.from_package(pkg.name)
		if not formatter.is_excluded(pkg.name, chain) then
			local specificity = #pkg.languages
			for _, lang in ipairs(pkg.languages) do
				for _, ft in ipairs(filetype.from_language(lang)) do
					local key = ft .. "\0" .. pkg.name
					if not seen[key] then
						seen[key] = true
						by_ft[ft] = by_ft[ft] or {}
						table.insert(by_ft[ft], { package = pkg.name, chain = chain, specificity = specificity })
					end
				end
			end
		end
	end
	for _, list in pairs(by_ft) do
		table.sort(list, function(a, b)
			if a.specificity ~= b.specificity then
				return a.specificity < b.specificity
			end
			return a.package < b.package
		end)
	end
	return by_ft
end

function M.formatters_by_ft()
	if cache then
		return cache
	end
	local out = {}
	for ft, list in pairs(M.candidates()) do
		out[ft] = vim.deepcopy(list[1].chain)
	end
	for ft, v in pairs(config.options.overrides) do
		out[ft] = v
	end
	cache = out
	return out
end

return M
