table.unpack = table.unpack or unpack -- 5.1 compatibility

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
--- @return string error
local function git_origin_url()
	local url = vim.fn.system("git remote get-url origin"):gsub("\n", "")
	if url == "" or string.find(url, "fatal") then
		return "", "not a git repository:" .. url
	end

	return url, ""
end

--- @class Selection
--- @field start_row integer
--- @field end_row integer

--- @return Selection
local function get_visual_selection()
	-- Get the start and end positions of the visual selection
	local _, start_row, _, _ = unpack(vim.fn.getpos("v"))
	local end_row, _ = unpack(vim.api.nvim_win_get_cursor(0))

	--- @type Selection
	return {
		start_row = start_row,
		end_row = end_row,
	}
end

--- @class Params
--- @field selection string
--- @field origin string
--- @field pwd string

--- @param params Params
local function execute_command(params)
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
	local path = vim.fn.expand('%:p'):sub(string.len(params.pwd) + 2)

	--- @type string
	local command
	if params.selection == "single_line" then
		local line, _ = unpack(vim.api.nvim_win_get_cursor(0))
		command = string.format("open %s/%s/%s#L%s", base_url, branch, path, line)
	elseif params.selection == "multi_line" then
		local selection = get_visual_selection()
		command = string.format("open %s/%s/%s#L%d-L%d", base_url, branch, path, selection.start_row, selection.end_row)
	end

	vim.fn.system(command)
end

M.open = function()
	local origin, error = git_origin_url()
	if error ~= "" then
		print(error)
		return
	end

	--- @type Params
	local params = {
		selection = "single_line",
		origin = origin,
		pwd = vim.fn.getcwd(),
	}

	vim.print("vim.print(config):", params)

	execute_command(params)
end


M.open_multiline = function()
	local origin, error = git_origin_url()
	if error ~= "" then
		print(error)
		return
	end

	--- @type Params
	local params = {
		selection = "multi_line",
		origin = origin,
		pwd = vim.fn.getcwd(),
	}

	vim.print("vim.print(config):", params)

	execute_command(params)
end

vim.keymap.set('n', '<leader>go', M.open, { noremap = true, silent = true, desc = "[G]it [O]pen in Web" })
vim.keymap.set('v', '<leader>go', M.open_multiline, { noremap = true, silent = true, desc = "[G]it [O]pen in Web" })
vim.keymap.set('v', '<leader>gg', get_visual_selection, { noremap = true, silent = true, desc = "[G]it [G] debug" })

return M
