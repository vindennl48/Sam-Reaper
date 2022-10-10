function scriptPath()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local json = require(scriptPath() .. 'json')

-- Convert a hex color to integers r,g,b
local function hex2rgb(num)
	
	if string.sub(num, 1, 2) == "0x" then
		num = string.sub(num, 3)
	end

	local red = string.sub(num, 1, 2)
	local blue = string.sub(num, 3, 4)
	local green = string.sub(num, 5, 6)
	
	red = tonumber(red, 16)
	blue = tonumber(blue, 16)
	green = tonumber(green, 16)
	
	return red, green, blue
	
end

-- Take discrete RGB values and return the combined integer
-- (equal to hex colors of the form 0xRRGGBB)
local function rgb2num(red, green, blue)
	
	green = green * 256
	blue = blue * 256 * 256
	
	return red + green + blue

end


--[[

local result = json.parse('{"name":"mitchell", "occupation":"badass"}', 1, "}")

reaper.ShowConsoleMsg("Name: " .. result["name"] .. ", Occupation: " .. result["occupation"] .. "\n")

local bit = require(scriptPath() .. "myfile")


local command = "\"." .. scriptPath() .. "index-macos\" -c ballsack"
reaper.ShowConsoleMsg("command: " .. command .. "\n\n")

--local result = os.execute('bash -c "echo hi"')
local result = reaper.ExecProcess(command, 0)

reaper.ShowConsoleMsg("result: " .. result .. "\n")

]]


-- ::Working code to get json from console::
local command = "\"." .. scriptPath() .. "console\" -l"
--   -- reaper.ShowConsoleMsg(command)
local result = reaper.ExecProcess(command, 0):sub(3)
--   -- reaper.ShowConsoleMsg(result)
local json_result = json.decode(result)
-- -- reaper.ShowConsoleMsg(json_result["data"][1])
-- for i, song in ipairs(json_result["data"]) do
--   reaper.ShowConsoleMsg(song .. '\n')
-- end

local function Main()
	local char = gfx.getchar()
	if char ~= 27 and char ~= -1 then
		reaper.defer(Main)
	end
	
	gfx.update()

  gfx.set(1, 0.5, 0.5, 1)
  gfx.line(10, 20, 80, 120)

  gfx.circle(40, 100, 20, 1)

  gfx.rect(200, 200, 200, 200, 0)

  gfx.roundrect(250, 420, 200, 50, 10)

  local my_str = ""

  gfx.setfont(1, "Arial", 28)

  gfx.x, gfx.y = 100, 100

  gfx.drawstr(json_result['data'][1] .. ", " .. json_result['data'][2])
end

gfx.clear = rgb2num(0, 0, 0)

-- gfx.init("name"[,width,height,dockstate, x, y])
--   dockstate: 0 for floating, 1 for docked
gfx.init("My Window", 640, 480, 0, 200, 200)
Main()

