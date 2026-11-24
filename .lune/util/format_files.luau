--[[

format_files

Selects owned Luau sources from Git's NUL-delimited tracked file list. Kept compatible
with the project's pinned Lune runtime.

--]]

local function formatFiles(trackedFiles: string): { string }
	assert(type(trackedFiles) == "string")

	local files = {}
	for path in string.gmatch(trackedFiles, "[^%z]+") do
		local root = string.match(path, "^([^/]+)/")
		local owned = root == ".lune" or root == "examples" or root == "lib" or root == "scripts" or root == "tests"
		if owned and string.match(path, "%.luau$") and not string.match(path, "^tests/data/") then
			table.insert(files, path)
		end
	end
	return files
end

return formatFiles
