--- Collection of APIs and utilities for LOVE2D games
---@module 'ELib'

local ELib = {
	_LICENSE = "MIT",
	_VERSION = "0.0.1",
	-- _URL = "https://github.com/EndeyshentLabs/entanglement-lib",
	_AUTHOR = "EndeyshentLabs",
	_DESCRIPTION = "Collection of APIs and utilities for LOVE2D games",

	__os__ = {},

	-- Modules
	save = {},
	mod = {},
	serial = {},
	net = {},
}

ELib.__index = ELib

function ELib:init()
	if package.config:sub(1, 1) == "\\" then
		self.ostype = "windows"
	else
		self.ostype = "unix"
	end
end

---Initialises mod API with `modpath`
---@param modpath any
function ELib.mod:init(modpath)
	self.modpath = modpath or "mods"

	if love.filesystem.isFused() then
		local dir = love.filesystem.getSourceBaseDirectory()
		local ok = love.filesystem.mount(dir, "self")
		self.modpath = "self/" .. self.modpath

		if not ok then
			error(("Unable to mount modpath (%s) directory!"):format(self.modpath))
		end
	else
		print("[Entanglement/WARN] External mods aren't supported on not fused executables")
	end
end

---Loads mods in `modpath`
---@return table mods
function ELib.mod:loadMods()
	self.moddirs = love.filesystem.getDirectoryItems(self.modpath)
	local mods = {}

	for _, dir in pairs(self.moddirs) do
		local modModulePath = self.modpath .. "/" .. dir
		local modModuleDirInfo = love.filesystem.getInfo(modModulePath)

		if not modModuleDirInfo then
			error("Unable to index mod module '" .. dir .. "'!")
		end

		if modModuleDirInfo.type == "directory" then
			local modModuleFiles = love.filesystem.getDirectoryItems(modModulePath)

			local initFound = false
			for _, file in pairs(modModuleFiles) do
				if file == "init.lua" then
					initFound = true
					break
				end
			end
			if not initFound then
				error(("Mod module '%s' lacks init.lua"):format(dir))
			end

			local modModule, errstr = love.filesystem.load(modModulePath .. "/init.lua")

			if not modModule then
				error(("Unable to load mod '%s': %s"):format(dir, errstr))
			end

			table.insert(mods, modModule())
			mods[#mods]._DIR_NAME = dir
			mods[#mods]._PATH = modModulePath
		end
	end

	return mods
end

function ELib.mod:validateMod(mod)
    local infoValid = mod._NAME and mod._VERSION
	local functionsValid = type(mod.load) == "function"

	return infoValid, functionsValid
end

return setmetatable({}, ELib)
