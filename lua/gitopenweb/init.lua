local M = {}

M.setup = function(opts)
	print("Options:", opts)
end

--- @param domain string
--- @param user string
--- @param repo string
--- @param branch string
--- @param path string
--- @param start_line integer
--- @param end_line integer?
--- @return string
local function format_url(domain, user, repo, branch, path, start_line, end_line)
	if not string.find(domain, "http") then
		domain = "https://" .. domain
	end
	if string.find(domain, "github") then
		repo = repo .. "/tree"
	end
	if string.find(domain, "gitlab") then
		repo = repo .. "/-/tree"
	end

	local lines = string.format("#L%d", start_line)
	if end_line then
		lines = string.format("#L%d-L%d", start_line, end_line)
	end

	return string.format("%s/%s/%s/%s/%s%s", domain, user, repo, branch, path, lines)
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

--- @class Opts
--- @field origin string?
--- @field mode string

--- TODO: Support linux with xdg-open command
--- @param opts Opts
--- @return string
local function build_command(opts)
	opts = opts or {}
	opts.mode = opts.mode or "n"

	local pattern
	if string.find(opts.origin, "git@") then
		pattern = "git@(.*):(.*)/(.*).git"
	elseif string.find(opts.origin, "http") then
		pattern = "http[s]?://(.*)/(.*)/(.*).git"
	end

	local parts = string.gmatch(opts.origin, pattern)
	local domain, user, repo = parts()
	local branch = vim.fn.system("git branch --show-current"):gsub("\n", "")
	local path = vim.fn.expand('%:p'):sub(string.len(vim.fn.getcwd()) + 2)

	local mode = string.lower(opts.mode)
	if mode == "n" then
		local line, _ = table.unpack(vim.api.nvim_win_get_cursor(0))
		return format_url(domain, user, repo, branch, path, line)
	elseif mode == "v" then
		local selection = get_visual_selection()
		return format_url(domain, user, repo, branch, path, selection.start_row, selection.end_row)
	end

	return ""
end

M.open = function()
	local origin, err = git_origin_url()
	if err ~= nil then
		print(err)
		return
	end

	--- @type Opts
	local opts = {
		origin = origin,
		mode = vim.fn.mode(),
	}

	local command = build_command(opts)
	vim.fn.system("open " .. command)
end

M.select = function()
	local origin, err = git_origin_url()
	if err ~= nil then
		print(err)
		return
	end

	--- @type Opts
	local opts = {
		origin = origin,
		mode = vim.fn.mode(),
	}

	local command = build_command(opts)
	vim.fn.system("echo " .. command .. " | pbcopy")
end

vim.keymap.set({ 'n', 'v' }, '<leader>go', M.open, { noremap = true, silent = true, desc = "[G]it [O]pen in Web" })
vim.keymap.set({ 'n', 'v' }, '<leader>gs', M.select,
	{ noremap = true, silent = true, desc = "[G]it [S]elect to clipboard" })

return M
