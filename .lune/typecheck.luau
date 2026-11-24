--> Run luau-lsp analysis to check for type errors

local process = require("@lune/process")

local CommandBuilder = require("./util/exec")

process.exit(
	CommandBuilder.new("luau-lsp")
		:withArg("analyze")
		:withArg("--platform=standard")
		:withArgs({ "--ignore", "'**/*_packages/**/*'" })
		:withArg(".")
		:withStdioStrategy("forward")
		:exec().code
)
