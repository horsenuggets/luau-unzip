--[[

format_files

Verifies that formatting selects only tracked project sources and preserves file names.

--]]

local frktest = require("../luau_packages/frktest")
local check = frktest.assert.check
local formatFiles = require("../.lune/util/format_files")

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
		local selected = formatFiles(input)
		check.equal(#selected, #paths)
		for index, path in paths do
			check.equal(selected[index], path)
			check.equal(formatFiles(input)[index], path)
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
			check.equal(#formatFiles(`{path}\0`), 0)
		end
		check.equal(#formatFiles(""), 0)
	end)
end
