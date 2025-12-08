local open = io.open
local concat = table.concat
local rlines = io.lines
local insert = table.insert
local tonumber = tonumber

local fl = {}

function fl.file_exists(file)
  local f = open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function fl.seek(file)
  if (fl.file_exists(file)) then
    local f = open(file, "rb")
    if (f ~= nil) then
      return f:read("*all")
    end
  end
end

function fl.lines_from(file, func)
  if not fl.file_exists(file) then return {} end
  local line_count = 0
  for line in rlines(file) do
    line_count = line_count + 1
    func(line_count, line)
  end
end

local function get_one(txt, id)
  return string.sub(txt, id, id)
end

-- local function unpack2(tbl)
--   return tbl[1], tbl[2]
-- end

-- local function gen_key(x, y)
--   return concat({x, "-", y})
-- end

local function check_surround(dict_map, x, y)
  local surround_count = 0
  for i_y = (y - 1), (y + 1) do
    for i_x = (x - 1), (x + 1) do
      if (i_x ~= x or i_y ~= y) then
        if (dict_map[i_y] and dict_map[i_y][i_x]) then
          surround_count = surround_count + 1
          if (surround_count >= 4) then
            return false
          end
        end
      end
    end
  end
  return surround_count < 4
end

local function q1(xy_cache)
  local take_count = 0

  for y, v in pairs(xy_cache) do
    for x, _ in pairs(v) do
      if (check_surround(xy_cache, x, y)) then
        take_count = take_count + 1
      end
    end
  end

  return take_count
end

local function q2(xy_cache)
  local take_count = 0

  local temp_take_count = 0
  local do_loop = true
  local to_remove_xy = {}
  local to_check_xy = xy_cache
  while (do_loop)
  do
    to_remove_xy = {}
    temp_take_count = 0
    for y, v in pairs(to_check_xy) do
      to_remove_xy[y] = {}
      for x, _ in pairs(v) do
        if (check_surround(to_check_xy, x, y)) then
          temp_take_count = temp_take_count + 1
          to_remove_xy[y][x] = 1
        end
      end
    end
    take_count = take_count + temp_take_count
    do_loop = (temp_take_count > 0)

    for y, v in pairs(to_remove_xy) do
      for x, _ in pairs(v) do
        to_check_xy[y][x] = nil
      end
    end
  end

  return take_count
end

local xy_cache = {}

fl.lines_from("input.txt", function(id_txt, txt)
  xy_cache[id_txt] = {}
  for x = 1, #txt do
    local letter = get_one(txt, x)
    if (letter == "@") then
      xy_cache[id_txt][x] = 1
    end
  end
end)

print(q2(xy_cache))



-- print(string.format("%.f",total_output))
