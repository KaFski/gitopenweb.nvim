local M = {}

table.unpack = table.unpack or unpack -- 5.1 compatibility

M.open = function()
	local pwd = vim.fn.getcwd()
	print("PWD:", pwd)

	local origin = vim.fn.system("git remote get-url origin")
	if origin == "" or string.find(origin, "fatal") then
		print("Not a git repository")
		return
	end

	print("Valid git repository")
	print("Result:", origin)

	local domain, user, repo, branch

	if string.find(origin, "git@") then
		print("SSH remote repository")
		local parts = string.gmatch(origin, "git@(.*):(.*)/(.*).git")

		domain, user, repo = parts()

		local branch = vim.fn.system("git branch --show-current"):gsub("\n", "")
		if origin == "" then
			print("Not a valid branch")
			return
		end

		local relative_path = vim.fn.expand('%:p')
		local path = string.sub(relative_path, string.len(pwd) + 2)
		local pos = vim.api.nvim_win_get_cursor(0)
		local system_command = string.format("open http://%s/%s/%s/tree/%s/%s#L%s", domain, user, repo, branch, path,
			pos[1])


		vim.fn.system(system_command)
	elseif string.find(origin, "https://") then
		print("HTTPS remote repository")
		local parts = string.gmatch(origin, "git@(.*):(.*)/(.*).git")

		domain, user, repo = parts()
		vim.fn.system(string.format("open http://%s/%s/%s", domain, user, repo))
	end
end

M.open()


M.setup = function(opts)
	print("Options:", opts)
end

-- local opened = {}
-- local last_window = 0
-- local last_run_definiton = ""
--
-- ---@class Opts
-- ---@field nonverbose boolean
--
-- -- Calculate height of the windows so it's not more than 50% of the screen
-- ---@param window number
-- ---@param size number
-- local function calculate_window_max_height(window, size)
-- 	local w_height = vim.api.nvim_win_get_height(window)
-- 	local half_w_height = math.ceil(w_height / 2)
--
--
-- 	if size > half_w_height then
-- 		size = half_w_height
-- 	elseif size < 5 then
-- 		size = 5
-- 	end
--
-- 	return size
-- end
--
--
--


M.cleanup = function()
	print("Cleanup called:")
end

return M
