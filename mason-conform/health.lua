local resolve = require("mason-conform.resolve")

local M = {}

function M.check()
	local h = vim.health
	h.start("mason-conform")

	if not pcall(require, "mason-registry") then
		return h.error("mason.nvim not found")
	end
	local ok_conform, conform = pcall(require, "conform")
	if not ok_conform then
		h.warn("conform.nvim not found")
	end

	local map = resolve.formatters_by_ft()
	local candidates = resolve.candidates()
	local fts = vim.tbl_keys(map)
	table.sort(fts)
	if #fts == 0 then
		return h.warn("no formatters installed via Mason")
	end

	for _, ft in ipairs(fts) do
		local chain = map[ft]
		local line = ("%s -> %s"):format(ft, table.concat(chain, ", "))

		local losers = {}
		for i = 2, #(candidates[ft] or {}) do
			losers[#losers + 1] = candidates[ft][i].package
		end
		if #losers > 0 then
			line = line .. ("	(also installed: %s)"):format(table.concat(losers, ", "))
		end

		local unknown, missing = {}, {}
		if ok_conform then
			for _, name in ipairs(chain) do
				if conform.get_formatter_config(name) == nil then
					unknown[#unknown + 1] = name
				elseif not conform.get_formatter_info(name).available then
					missing[#missing + 1] = name
				end
			end
		end

		if #unknown > 0 then
			h.error(line .. ("	(not a conform formatter: %s)"):format(table.concat(unknown, ", ")))
		elseif #missing > 0 then
			h.warn(line .. ("	(binary not found: %s)"):format(table.concat(missing, ", ")))
		else
			h.ok(line)
		end
	end
end

return M
