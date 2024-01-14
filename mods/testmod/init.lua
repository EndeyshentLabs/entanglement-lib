local M = {
	_NAME = "Test mod PauseChamp",
	_DESCRIPTION = "Mod made to test entanglement-lib's mod module",
	_AUTHOR = "Not EndeyshentLabs",
	_VERSION = "4.2.0",
}

function M.load()
	print("Hello from mod!")
	print("My path is '" .. M._PATH .. "'")
	Jebaited = love.graphics.newImage(M._PATH .. "/gfx/Jebaited.png")
end

function M.draw()
	love.graphics.setColor(1, 0, 0)
	love.graphics.print("Drawing from mod :monkaS:", 420, 69)

	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(Jebaited, 40, 40)
end

return M
