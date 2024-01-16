--- Collection of APIs and utilities for LOVE2D games
---@module 'ELib'

local ELib = {
	_LICENSE = "MIT",
	_VERSION = "0.0.1",
	_URL = "https://github.com/EndeyshentLabs/entanglement-lib",
	_AUTHOR = "EndeyshentLabs",
	_DESCRIPTION = "Collection of APIs and utilities for LOVE2D games",

	__os__ = {},

	-- Modules
	save = {},
	mod = {
		_INITIALIZED = false,
	},
	serial = {},
	net = {},
	log = {},
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
	if self._INITIALIZED then
		ELib.log:warn("Reinitializing modules is not recommended!", "Entanglement")
	end

	self.modpath = modpath or "mods"

	if love.filesystem.isFused() then
		local dir = love.filesystem.getSourceBaseDirectory()
		local ok = love.filesystem.mount(dir, "self")
		self.modpath = "self/" .. self.modpath

		if not ok then
			error(("Unable to mount modpath (%s) directory!"):format(self.modpath))
		end
	else
		ELib.log:warn("External mods aren't supported in not fused executables", "Entanglement")
	end

	self._INITIALIZED = true
end

---Loads mods in `modpath`
---@return table mods
function ELib.mod:loadMods()
	if not self._INITIALIZED then
		error("Entanglement module `mod` wasn't initialized!")
	end

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

---@enum ELib.LogLevel
ELib.log.LogLevel = {
	INFO = "INFO",
	WARN = "WARN",
	ERROR = "ERROR",
	FATAL = "FATAL",
	DEBUG = "DEBUG",
}

---Log `msg` to stdout or stderr with `level`
---@param level ELib.LogLevel
---@param msg string
---@param author string?
function ELib.log:log(level, msg, author)
	local buf = io.stdout
	if level == self.LogLevel.FATAL or level == self.LogLevel.FATAL then
		buf = io.stderr
	end
	if not author then
		buf:write(("[%s] %s\n"):format(level, msg))
	else
		buf:write(("[%s/%s] %s\n"):format(author, level, msg))
	end
end

---Wrapper function for `log:log()` for `LogLevel::INFO`
---@param msg string
---@param author string?
function ELib.log:info(msg, author)
	self:log(self.LogLevel.info, msg, author)
end

---Wrapper function for `log:log()` for `LogLevel::WARN`
---@param msg string
---@param author string?
function ELib.log:warn(msg, author)
	self:log(self.LogLevel.WARN, msg, author)
end

---Wrapper function for `log:log()` for `LogLevel::ERROR`
---@param msg string
---@param author string?
function ELib.log:error(msg, author)
	self:log(self.LogLevel.ERROR, msg, author)
end

---Wrapper function for `log:log()` for `LogLevel::FATAL`
---@param msg string
---@param author string?
function ELib.log:fatal(msg, author)
	self:log(self.LogLevel.FATAL, msg, author)
end

---Wrapper function for `log:log()` for `LogLevel::DEBUG`
---@param msg string
---@param author string?
function ELib.log:debug(msg, author)
	self:log(self.LogLevel.DEBUG, msg, author)
end

return setmetatable({}, ELib)
