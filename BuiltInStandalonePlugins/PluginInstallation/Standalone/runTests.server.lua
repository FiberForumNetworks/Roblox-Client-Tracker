local Plugin = script.Parent.Parent
local TestsFolderPlugin = Plugin.Src
local TestsFolderPackages = Plugin.Packages -- Can be used to run package's unit tests

local TestEZ = require(Plugin.Packages.TestEZ)
local TestBootstrap = TestEZ.TestBootstrap
local TextReporter = TestEZ.Reporters.TextReporterQuiet -- Remove Quite to see output

local SHOULD_RUN_TESTS = false -- Do not check in as true!
if SHOULD_RUN_TESTS then
	print("----- All PluginInstallation Tests ------")
	TestBootstrap:run({ TestsFolderPlugin, TestsFolderPackages }, TextReporter)
	print("----------------------------------")
end