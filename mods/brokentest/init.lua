local M = {
	_DESCRIPTION = "Broken mod made to test entanglement-lib's mod module",
	_AUTHOR = "Not EndeyshentLabs",
	_VERSION = "4.2.0",
}

function M.draw()
	love.graphics.setColor(1, 0, 0)
	love.graphics.print("Drawing from mod :monkaS:", 420, 69)

	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(Jebaited, 40, 40)
end

return M
