local open = io.open
local concat = table.concat
local rlines = io.lines
local insert = table.insert
local tonumber = tonumber
local sub = string.sub
local max = math.max
local min = math.min

local function file_exists(file)
  local f = open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

local function seek(file)
  if (file_exists(file)) then
    local f = open(file, "rb")
    if (f ~= nil) then
      return f:read("*all")
    end
  end
end

local function lines_from(file, func)
  local line_count = 0
  for line in rlines(file) do
    line_count = line_count + 1
    func(line_count, line)
  end
end

local function get_one(txt, id)
  return sub(txt, id, id)
end

local function find_idx(txt, pattern, ist)
  return string.find(txt, pattern, ist)
end

local function split(input, pattern, func)
  for data in input:gmatch(pattern) do
    func(data)
  end
end

--- func desc
---@param id_txt number
---@param txt string
local function q1_process_input(id_txt, txt)
  if (id_txt == 5) then
    local operators = txt:gmatch("[+?*]")
    local array = {}
    for k, _ in operators do
      insert(array, k)
    end
    return array, id_txt
  else
    local numbers = txt:gmatch("%d+")
    local array = {}
    for k, _ in numbers do
      insert(array, k)
    end
    return array, id_txt
  end
end

local function q1()
  local filename = "input.txt"
  local line_count = 0
  local input_raw = {}
  local total = 0
  for line in rlines(filename) do
    line_count = line_count + 1
    local raw, raw_index = q1_process_input(line_count, line)
    if (raw_index == 5) then
      for k, operator in pairs(raw) do
        if (operator == "+") then
          total = total + (input_raw[1][k] + input_raw[2][k] + input_raw[3][k] + input_raw[4][k])
        else
          total = total + (input_raw[1][k] * input_raw[2][k] * input_raw[3][k] * input_raw[4][k])
        end
      end
    else
      input_raw[raw_index] = raw
    end
  end
  return (total)
end

--- func desc
---@param id_txt number
---@param op_line number
---@param txt string
local function q2_process_input(id_txt, txt, op_line)
  if (id_txt == op_line) then
    return txt, id_txt
  else
    return txt, id_txt
  end
end

-- local function pad(input, padding, times, max_digit, original)
--   local pad_tbl = {}
--   for i = 1, times do
--     insert(pad_tbl, padding)
--   end
--   insert(pad_tbl, input)
--   return concat(pad_tbl)
-- end

local function sum(input_1, input_2, input_3, input_4)
  local string_1 = tostring(input_1)
  local string_2 = tostring(input_2)
  local string_3 = tostring(input_3)
  local string_4 = tostring(input_4)

  local result

  local max_digit = max(#string_1, #string_2, #string_3, #string_4)

  for k = max_digit, 1, -1 do
    local new_str = concat({
      get_one(string_1, k),
      get_one(string_2, k),
      get_one(string_3, k),
      get_one(string_4, k)
    })
    local new_num = tonumber(new_str)
    if (new_num) then
      if (result == nil) then
        result = tonumber(new_num)
      else
        result = result + tonumber(new_num)
      end
    end
  end

  return result
end

local function mul(input_1, input_2, input_3, input_4)
  local string_1 = tostring(input_1)
  local string_2 = tostring(input_2)
  local string_3 = tostring(input_3)
  local string_4 = tostring(input_4)

  local result

  local max_digit = max(#string_1, #string_2, #string_3, #string_4)

  for k = max_digit, 1, -1 do
    local new_str = concat({
      get_one(string_1, k),
      get_one(string_2, k),
      get_one(string_3, k),
      get_one(string_4, k)
    })
    local new_num = tonumber(new_str)
    if (new_num) then
      if (result == nil) then
        result = tonumber(new_num)
      else
        result = result * tonumber(new_num)
      end
    end
  end

  return result
end

local function q2()
  local filename = "input.txt"
  local line_count = 0
  local input_raw = {}
  local total = 0
  for line in rlines(filename) do
    line_count = line_count + 1
    local raw, raw_index = q2_process_input(line_count, line, 5)
    if (raw_index == 5) then
      local k = 1
      while (k <= # raw) do
        local result
        local operator_idx = find_idx(raw, "[+?*]", k)
        if (operator_idx) then
          local operator_idx_next = find_idx(raw, "[+?*]", operator_idx + 1) or (#raw + 1)
          local operator = get_one(raw, operator_idx)
          if (operator == "+") then
            result = sum(
              string.sub(input_raw[1], k, operator_idx_next - 1),
              string.sub(input_raw[2], k, operator_idx_next - 1),
              string.sub(input_raw[3], k, operator_idx_next - 1 ),
              string.sub(input_raw[4], k, operator_idx_next - 1)
            )
          elseif (operator == "*") then
            result = mul(
              string.sub(input_raw[1], k, operator_idx_next - 1),
              string.sub(input_raw[2], k, operator_idx_next - 1),
              string.sub(input_raw[3], k, operator_idx_next - 1),
              string.sub(input_raw[4], k, operator_idx_next - 1)
            )
          else
          end
          if (result ~= nil) then
            total = total + result
          end
          k = (operator_idx_next) or (k + 1)
        end
      end
    else
      input_raw[raw_index] = raw
    end
  end
  return (total)
end

print(string.format("%.f", q2()))
