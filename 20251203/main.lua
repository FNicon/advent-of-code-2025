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

local function find_largest(txt, right_length)
  for i = 9, 1, -1 do
    local _left = string.find(txt, tostring(i), 1)
    if (_left ~= nil) then
      if (_left + right_length <= #txt) then
        local _check = string.sub(txt, _left + 1)
        return i, _check
      end
    end
  end
end

local question = {}

function question.q1(_txt)
  local left_max, right, right_max
  left_max, right = find_largest(_txt, 1)
  right_max, _ = find_largest(right, 0)
  local res = tonumber(concat({left_max, right_max}))
  return res
end

function question.q2(_txt, max_digit)
  local remaining = _txt
  local num = {}
  local check_length = max_digit
  for i = check_length, 1, -1 do
    local new_num = 0
    new_num, remaining = find_largest(remaining, i - 1)
    insert(num, new_num)
  end
  local res = tonumber(concat(num))
  return res
end

local total_output = 0

fl.lines_from("input.txt", function(id_txt, txt)
  local res = question.q2(txt, 12)
  total_output = total_output + res
end)

print(string.format("%.f",total_output))
