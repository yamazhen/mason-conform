local M = {}

local registered = false

function M.installed_formatters()
	local ok, registry = pcall(require, "mason-registry")
	if not ok then
		return {}
	end
	local ok_pkgs, pkgs = pcall(registry.get_installed_packages)
	if not ok_pkgs then
		return {}
	end

	local out = {}
	for _, pkg in ipairs(pkgs) do
		local spec = pkg.spec or {}
		if vim.tbl_contains(spec.categories or {}, "Formatter") then
			out[#out + 1] = { name = pkg.name, languages = spec.languages or {} }
		end
	end
	return out
end

function M.on_change(fn)
	if registered then
		return
	end
	local ok, registry = pcall(require, "mason-registry")
	if not ok then
		return
	end
	registered = true
	for _, ev in ipairs({ "package:install:success", "package:uninstall:success" }) do
		pcall(function()
			registry:on(ev, vim.schedule_wrap(fn))
		end)
	end
end

return M
