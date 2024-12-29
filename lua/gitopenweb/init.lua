local M = {}

M.setup = function(opts)
	print("Options:", opts)
end

--- @param domain string
--- @param user string
--- @param repo string
--- @return string
local function build_url(domain, user, repo)
	if not string.find(domain, "http") then
		domain = "https://" .. domain
	end
	if string.find(domain, "github") then
		repo = repo .. "/tree"
	end
	if string.find(domain, "gitlab") then
		repo = repo .. "/-/tree"
	end

	return string.format("%s/%s/%s", domain, user, repo)
end

--- @return string url
--- @return string? err
local function git_origin_url()
	local url = vim.fn.system("git remote get-url origin"):gsub("\n", "")
	if url == "" or string.find(url, "fatal") then
		return "", "not a git repository:" .. url
	end

	return url, nil
end

--- @class Selection
--- @field start_row integer
--- @field end_row integer

--- @return Selection
local function get_visual_selection()
	-- Get the start and end positions of the visual selection
	-- more: help getpos & help line
	local _, start_row, _, _ = table.unpack(vim.fn.getpos("v"))
	local end_row, _ = table.unpack(vim.api.nvim_win_get_cursor(0))

	--- @type Selection
	return {
		start_row = start_row,
		end_row = end_row,
	}
end

--- @class Params
--- @field origin string
--- @field selection string

--- TODO: Support linux with xdg-open command
--- @param params Params
--- @return string
local function build_command(params)
	local pattern
	if string.find(params.origin, "git@") then
		pattern = "git@(.*):(.*)/(.*).git"
	elseif string.find(params.origin, "http") then
		pattern = "http[s]?://(.*)/(.*)/(.*).git"
	end

	local parts = string.gmatch(params.origin, pattern)
	local domain, user, repo = parts()
	local base_url = build_url(domain, user, repo)

	local branch = vim.fn.system("git branch --show-current"):gsub("\n", "")
	local path = vim.fn.expand('%:p'):sub(string.len(vim.fn.getcwd()) + 2)

	if params.selection == "single_line" then
		local line, _ = table.unpack(vim.api.nvim_win_get_cursor(0))
		return string.format("%s/%s/%s#L%s", base_url, branch, path, line)
	elseif params.selection == "multi_line" then
		local selection = get_visual_selection()
		return string.format("%s/%s/%s#L%d-L%d", base_url, branch, path, selection.start_row, selection.end_row)
	end

	return ""
end

--- TODO: Think if refactor methods by providing args instead of copy & past functions
M.open = function()
	local origin, err = git_origin_url()
	if err ~= nil then
		print(err)
		return
	end

	--- @type Params
	local params = {
		origin = origin,
		selection = "single_line",
	}

	local command = build_command(params)
	vim.fn.system("open" .. command)
end

M.select = function()
	local origin, err = git_origin_url()
	if err ~= nil then
		print(err)
		return
	end

	--- @type Params
	local params = {
		origin = origin,
		selection = "single_line",
	}

	local command = build_command(params)
	vim.fn.system("echo " .. command .. " | pbcopy")
end


M.open_multiline = function()
	local origin, err = git_origin_url()
	if err ~= nil then
		print(err)
		return
	end

	--- @type Params
	local params = {
		origin = origin,
		selection = "multi_line",
	}

	local command = build_command(params)
	vim.fn.system("open" .. command)
end

M.select_multiline = function()
	local origin, err = git_origin_url()
	if err ~= nil then
		print(err)
		return
	end

	--- @type Params
	local params = {
		origin = origin,
		selection = "single_line",
	}

	local command = build_command(params)
	vim.fn.system("echo " .. command .. " | pbcopy")
end

vim.keymap.set('n', '<leader>go', M.open, { noremap = true, silent = true, desc = "[G]it [O]pen in Web" })
vim.keymap.set('n', '<leader>gs', M.select, { noremap = true, silent = true, desc = "[G]it [S]elect to clipboard" })
vim.keymap.set('v', '<leader>go', M.open_multiline, { noremap = true, silent = true, desc = "[G]it [O]pen in Web" })
vim.keymap.set('v', '<leader>gs', M.select_multiline,
	{ noremap = true, silent = true, desc = "[G]it [S]elect to clipboard" })

return M
