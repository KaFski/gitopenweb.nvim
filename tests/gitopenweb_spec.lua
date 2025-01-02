local format_url = require("gitopenweb")._format_url

describe("gitopenweb.format_url", function()
	it("should format single line url", function()
		assert.are.same(
			"https://github.com/user/repo/tree/master/file/path.lua#L10",
			format_url("github.com", "user", "repo", "master", "file/path.lua", 10)
		)
	end)

	it("should format multi line url", function()
		assert.are.same(
			"https://github.com/user/repo/tree/master/file/path.lua#L10-L20",
			format_url("github.com", "user", "repo", "master", "file/path.lua", 10, 20)
		)
	end)
end)
