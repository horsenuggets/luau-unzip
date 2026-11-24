--[[

format_files

Verifies that formatting selects only tracked project sources and preserves file names.

--]]

local frktest = require("../luau_packages/frktest")
local check = frktest.assert.check
local formatFiles = require("../.lune/util/format_files")

local function exists(_path: string): boolean
	return true
end

return function(test: typeof(frktest.test))
	test.case("Formatting selects tracked owned sources without changing their order", function()
		local paths = {
			".lune/fmt.luau",
			"examples/tour.luau",
			"lib/init.luau",
			"scripts/generate_invalid_version_zip.luau",
			"tests/path.luau",
			"lib/a file with spaces.luau",
		}
		local input = `{table.concat(paths, "\0")}\0`
		local selected = formatFiles(input, exists)
		check.equal(#selected, #paths)
		for index, path in paths do
			check.equal(selected[index], path)
			check.equal(formatFiles(input, exists)[index], path)
		end
	end)

	test.case("Formatting excludes dependencies, worktrees, fixtures, and non-source files", function()
		local paths = {
			".wt/chore/example/lib/init.luau",
			".worktrees/example/lib/init.luau",
			"Submodules/library/init.luau",
			"luau_packages/frktest/init.luau",
			"lune_packages/tool/init.luau",
			"tests/data/fixture.luau",
			"lib/README.md",
			"lib/not-luau",
		}
		for _, path in paths do
			check.equal(#formatFiles(`{path}\0`, exists), 0)
		end
		check.equal(#formatFiles("", exists), 0)
	end)

	test.case("Formatting skips unstaged deletions while retaining existing sources", function()
		local selected = formatFiles("lib/init.luau\0lib/deleted.luau\0tests/path.luau\0", function(path)
			return path ~= "lib/deleted.luau"
		end)
		check.equal(#selected, 2)
		check.equal(selected[1], "lib/init.luau")
		check.equal(selected[2], "tests/path.luau")
	end)
end
