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

--- @return table
local function get_visual_selection()
	-- Get the start and end positions of the visual selection
	local _, start_row, _, _ = unpack(vim.fn.getpos("'<"))
	local _, end_row, _, _ = unpack(vim.fn.getpos("'>"))

	return {
		start_row = start_row,
		end_row = end_row,
	}
end


M.open = function()
	local pwd = vim.fn.getcwd()
	local origin = vim.fn.system("git remote get-url origin")
	if origin == "" or string.find(origin, "fatal") then
		print("Not a git repository")
		return
	end

	print("Result:", origin)

	local domain, user, repo, branch

	if string.find(origin, "git@") then
		print("SSH remote repository")
		local parts = string.gmatch(origin, "git@(.*):(.*)/(.*).git")

		domain, user, repo = parts()
		local baseURL = build_url(domain, user, repo)

		local branch = vim.fn.system("git branch --show-current"):gsub("\n", "")
		local path = vim.fn.expand('%:p'):sub(string.len(pwd) + 2)
		local line, _ = unpack(vim.api.nvim_win_get_cursor(0))
		local system_command = string.format("open %s/%s/%s#L%s", baseURL, branch, path, line)

		print("Command:", system_command)

		vim.fn.system(system_command)
	elseif string.find(origin, "https://") then
		print("HTTPS remote repository")
		-- TODO: Implement HTTPS remote repository
	end
end

M.open_multiline = function()
	local pwd = vim.fn.getcwd()
	local origin = vim.fn.system("git remote get-url origin")
	if origin == "" or string.find(origin, "fatal") then
		print("Not a git repository")
		return
	end

	local domain, user, repo, branch

	if string.find(origin, "git@") then
		print("SSH remote repository")
		local parts = string.gmatch(origin, "git@(.*):(.*)/(.*).git")

		domain, user, repo = parts()
		local baseURL = build_url(domain, user, repo)

		local branch = vim.fn.system("git branch --show-current"):gsub("\n", "")
		local path = vim.fn.expand('%:p'):sub(string.len(pwd) + 2)
		local pos = get_visual_selection()
		local system_command = string.format("open %s/%s/%s#L%d-L%d", baseURL, branch, path, pos.start_row, pos.end_row)

		print("Command:", system_command)

		vim.fn.system(system_command)
	elseif string.find(origin, "https://") then
		print("HTTPS remote repository")
		-- TODO: Implement HTTPS remote repository
	end
end

vim.keymap.set('n', '<leader>go', M.open, { noremap = true, silent = true })
vim.keymap.set('v', '<leader>go', M.open_multiline, { noremap = true, silent = true })

return M
