local KEY = {
	UP = 259,
	DOWN = 258,
	LEFT = 260,
	RIGHT = 261,
	
	H = 104, --72,
	ENTER = 10,
	
	ESC = 27,
	F1 = 265,
}

local pos = {
	x = 5,
	y = 5
}

function drawScreen()
	-- print(8, 8, "Generate")
	-- print(10, 8, "Enter seed: ")

	rectangle(0, 0, 79, 24)
	rectangle(33, 1, 77, 23)

	rectangle(2, 1, 31, 3)
	print(4, 2, "*** Derivative Dungeon ***")

	rectangle(2, 4, 31, 6)
	print(4, 5, "EXP / Next:")
	print(19, 5, "1200 / 1500")

	rectangle(2, 7, 31, 13)
	print(4, 8, "Life:")
	print(4, 10, "Magic:")
	print(4, 12, "Attack:")
	
	print(14, 8, "Lvl 3")
	print(14, 10, "Lvl 1")
	print(14, 12, "Lvl 2")

	print(23, 8, "24 / 32")
	print(23, 10, "16 / 16")

	rectangle(2, 14, 31, 20)
	print(4, 15, "Equipped:")
	-- print(9, 17, "Sword")
	-- print(9, 18, "Chainmail")
	-- print(9, 19, "None")
	
	rectangle(2, 21, 31, 23)
	print(4, 22, "Press [H] for help")

	for i = 0, 10 do
		print(35, i * 2 + 2, ".   .   .   .   .   .   .   .   .   .   .")
	end
	
	print(35 + pos.x * 4, pos.y * 2 + 2, "@")
end

function update()
	drawScreen()
	
	local ch = getch()
	
	if (ch == KEY.UP) then
		pos.y = pos.y - 1
		if (pos.y < 0) then
			pos.y = 10
		end
	end
	if (ch == KEY.DOWN) then
		pos.y = pos.y + 1
		if (pos.y > 10) then
			pos.y = 0
		end
	end
	if (ch == KEY.LEFT) then
		pos.x = pos.x - 1
		if (pos.x < 0) then
			pos.x = 10
		end
	end
	if (ch == KEY.RIGHT) then
		pos.x = pos.x + 1
		if (pos.x > 10) then
			pos.x = 0
		end
	end

	if (ch == KEY.F1) then
		loadScript("../script/main.lua")
	end
	
	if (ch == KEY.H) then
	end

	if (ch == KEY.ESC) then
		quit()
	end
	
end
