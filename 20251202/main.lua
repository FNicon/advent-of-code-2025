local open = io.open
local concat = table.concat

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

local string_op = {}

function string_op.split(input, pattern, func)
  for data in input:gmatch(pattern) do
    func(data)
  end
end

function string_op.check_repeat_1(input, func)
  local n = tostring(input)
  if (#n%2 == 0) then
    local pattern1 = n:sub(1, #n/2)
    local pattern2 = n:sub(#n/2 + 1)
    if (pattern1 == pattern2) then
      local new_number = tonumber(concat({pattern1, pattern2}))
      func(new_number)
    end
  end
end

function string_op.check_repeat_2(input, func)
  local n = tostring(input)
  if (#n > 1) then
    -- it's factor have odd number
    if (#n == 9) then
      -- check 3 x 3
      local same_pattern_1 = true
      for i = 0, 1 do
        same_pattern_1 = same_pattern_1 and string_op.is_repeat_next(n, 1 + (i * 3), 1 + ((i + 1) * 3), 3)
      end
      if (same_pattern_1) then
        func(input)
      end
    -- it's factor have odd number
    elseif (#n == 6) then
      -- check 3 x 2
      local same_pattern_2 = string_op.is_repeat_next(n, 1, (#n/2) + 1, (#n/2))
      if (same_pattern_2) then
        func(input)
      else
        -- check 2 x 3
        local same_pattern_1 = true
        for i = 0, 1 do
          same_pattern_1 = same_pattern_1 and string_op.is_repeat_next(n, 1 + (i * 2), 1 + ((i + 1) * 2), 2)
        end
        if (same_pattern_1) then
          func(input)
        end
      end
    -- it's factor have odd number
    elseif (#n == 10) then
      -- check 5 x 2
      local same_pattern_2 = string_op.is_repeat_next(n, 1, (#n/2) + 1, (#n/2))
      if (same_pattern_2) then
        func(input)
      else
        -- check 2 x 5
        local same_pattern_1 = true
        for i = 0, 3 do
          same_pattern_1 = same_pattern_1 and string_op.is_repeat_next(n, 1 + (i * 2), 1 + ((i + 1) * 2), 2)
        end
        if (same_pattern_1) then
          func(input)
        end
      end
    -- it's an even number (2, 4, 8)
    elseif (#n % 2 == 0) then
      local same_pattern = string_op.is_repeat_next(n, 1, (#n/2) + 1, #n/2)
      if (same_pattern) then
        func(input)
      end
    -- prime number (3, 5, 7)
    elseif (#n % 2 == 1) then
      local same_pattern = true
      for i = 1, (#n-1) do
        same_pattern = same_pattern and string_op.is_repeat_next(n, i, i + 1, 1)
      end
      if (same_pattern) then
        func(input)
      end
    end
  end
end

function string_op.is_repeat_next(n, id1, id2, char_length)
  if (char_length == 0) then
    return false
  end
  local pattern1 = n:sub(id1, id1 + char_length - 1)
  local pattern2 = n:sub(id2, id2 + char_length - 1)
  if (pattern1 == pattern2) then
    return true
  end
end

local input = fl.seek("input.txt")
local pattern_comma = "[^,]+"
local pattern_dash = "[^-]+"

local index_start = 0
local index_end = 0
local result = 0

string_op.split(input, pattern_comma, function(e)
  index_start = 0
  index_end = 0
  string_op.split(e, pattern_dash, function (d)
    if (index_start ~= 0) then
      index_end = d
    else
      index_start = d
    end
  end)

  for i = index_start, index_end do
    string_op.check_repeat_2(i, function(n)
      result = result + n
    end)
  end
  index_end = 0
  index_start = 0
end)

print(result)
