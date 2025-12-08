local textend = require("textend")
local finput = require("input")

local rot_start = 50
local rot_min = 0
local rot_max = 99

local cur_rot = 50
local prev_rot = 0
local diff = 0

local zero_count = 0

local div_res = 0
local function process_rotate(line_id, rotate_input)
    prev_rot = cur_rot
    local indicator = rotate_input:sub(1, 1)
    if (indicator == "L") then
        if (cur_rot == 0) then
            zero_count = zero_count - 1
        end
        cur_rot, div_res = textend.lpush(cur_rot, rotate_input:sub(2), rot_min, rot_max)
        zero_count = zero_count - div_res
        if (cur_rot == 0) then
            zero_count = zero_count + 1
        end
    elseif (indicator == "R") then
        cur_rot, div_res = textend.rpush(cur_rot, rotate_input:sub(2), rot_min, rot_max)
        zero_count = zero_count + div_res
    end
    diff = (cur_rot - prev_rot) + (div_res * (rot_max + 1))
    return zero_count
end

function love.load()
    local result = finput.lines_from(
        "input.txt",
        process_rotate
    )
    print(zero_count)

    print(textend.test_div(-3, 100))
end

function love.update(dt)
end

function love.draw()
end