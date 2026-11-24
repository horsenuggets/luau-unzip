--> Run StyLuau on tracked, project-owned sources only.

local process = require("@lune/process")
local formatFiles = require("./util/format_files")

local tracked = process.exec("git", { "ls-files", "-z", "--cached" })
assert(tracked.ok, tracked.stderr)
local files = formatFiles(tracked.stdout)
if #files == 0 then
	process.exit(0)
end

local args = table.clone(process.args)
table.insert(args, "--")
for _, path in files do
	table.insert(args, path)
end
process.exit(process.exec("styluau", args, { stdio = "inherit" }).code)
