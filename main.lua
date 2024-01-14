ELib = require("elib")

local loadedMods = {}

function love.load()
	ELib:init()
	ELib.mod:init()
	local mods = ELib.mod:loadMods()

	for _, v in pairs(mods) do
		print(("Loading mod '%s@%s' (%s)"):format(v._NAME, v._VERSION, v._DIR_NAME))
		v.load()
		print(("Successfully loaded mod '%s@%s' (%s)"):format(v._NAME, v._VERSION, v._DIR_NAME))
		table.insert(loadedMods, v)
	end
end

function love.update(dt)
	for _, v in pairs(loadedMods) do
		if v.update then
			v.update(dt)
		end
	end
end

function love.draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Loaded mods:")
	for k, v in ipairs(loadedMods) do
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(("- %s@%s (%s)"):format(v._NAME, v._VERSION, v._DIR_NAME), 0, love.graphics.getFont():getHeight() * k)
		if v.draw then
			v.draw()
		end
	end
end
