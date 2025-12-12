local open = io.open
local concat = table.concat
local rlines = io.lines
local insert = table.insert
local tonumber = tonumber
local sub = string.sub
local max = math.max
local min = math.min
local find = string.find
local gmatch = string.gmatch
local tostring = tostring

local function get_one(txt, id)
  return sub(txt, id, id)
end

local function find_idx(txt, pattern, ist)
  return find(txt, pattern, ist or 1)
end

local function evaluate_source(source, target)
  return source == target
end

local function apply_path(source, path, buttons)
  local button = buttons[path]
  local temp = {}
  local temp_source = {}
  local effect_id = 1
  for source_num in source:gmatch("[%d+]") do
    insert(temp_source, source_num)
  end
  for check in button:gmatch("[%d+]") do
    if (check == "1") then
      if (temp_source[effect_id] == "0") then
        temp[effect_id] = "1"
      else
        temp[effect_id] = "0"
      end
    else
      temp[effect_id] = temp_source[effect_id]
    end
    effect_id = effect_id + 1
  end
  return concat(temp, "<")
end

local function clone_steps(steps)
  local clone = {}
  for k, step in pairs(steps) do
    clone[k] = step
  end
  return clone
end

local function remove_steps(steps)
  for k = #steps, 1, -1 do
    steps[k] = nil
    table.remove(steps, k)
  end
  steps = nil
end

local function generate_plans(source, target, buttons)
  local step_id = 1

  local is_equal = evaluate_source(source, target)
  local is_equal_found = false
  local prev_source = {}
  local current_source = {}
  local chosen_step = ""
  while not is_equal and not is_equal_found do
    for k, button in pairs(buttons) do
      if (step_id == 1) then
        local to_check_source = source
        to_check_source = apply_path(to_check_source, k, buttons)

        if (current_source[to_check_source] == nil) then
          current_source[to_check_source] = concat({k})
          is_equal = evaluate_source(to_check_source, target)
          if (is_equal) then
            chosen_step = concat({k})
            is_equal_found = true
            break
          end
        end
      else
        for p_source, id in pairs(prev_source) do
          local to_check_source = p_source
          to_check_source = apply_path(to_check_source, k, buttons)

          if (current_source[to_check_source] == nil) then
            current_source[to_check_source] = prev_source[p_source]
            current_source[to_check_source] = current_source[to_check_source] .. "<" .. k
            is_equal = evaluate_source(to_check_source, target)
            if (is_equal) then
              chosen_step = current_source[to_check_source]
              is_equal_found = true
              break
            end
          end
        end
        if (is_equal_found) then
          break
        end
      end
    end
    local temp_key = {}
    for k, v in pairs(current_source) do
      prev_source[k] = v
      insert(temp_key, k)
    end
    for k, v in pairs(temp_key) do
      current_source[v] = nil
    end
    step_id = step_id + 1
  end
  return step_id - 1, chosen_step, is_equal, is_equal_found
end

local function battery_to_bit(battery)
  local temp = {}
  for k, v in pairs(battery) do
    if (v > 0) then
      temp[k] = 1
    else
      temp[k] = 0
    end
  end
  return concat(temp)
end

local function evaluate_batteries(source, target)
  return source == target
end

local function delta_batteries(source, target)
  local delta = {}
  local temp_source = {}
  local temp_target = {}
  for source_num in source:gmatch("[%d+]") do
    insert(temp_source, source_num)
  end
  for source_num in target:gmatch("[%d+]") do
    insert(temp_target, source_num)
  end
  local is_overload = false
  for k, v in pairs(temp_source) do
    local temp_num = tonumber(temp_target[k]) - tonumber(v)
    if (temp_num < 0) then
      is_overload = true
    end
    delta[k] = temp_num
  end
  return concat(delta, "<"), is_overload
end

local function apply_battery(battery, plan, buttons)
  local count = 0
  for k, v in pairs(plan) do
    local buttons_length = #buttons[v]
    local idx = 1
    while idx <= buttons_length do
      local bi = find(buttons[v], "1", idx)
      if (bi) then
        battery[bi] = battery[bi] + 1
      end
      idx = idx + (bi or 1)
    end
    count = count + 1
  end
  return count
end

local function clone_batteries(batteries)
  local temp = {}
  for k, v in pairs(batteries) do
    temp[k] = v
  end
  return temp
end

-- local function create_source_battery(delta)
--   local temp = {}
--   for k, v in pairs(delta) do
--     if (v > 0) then
--       temp[k] = 0
--     else
--       temp[k] = 1
--     end
--   end
--   return temp
-- end

local function is_battery_overload(delta)
  local clone = {}
  for source_num in delta:gmatch("[%d+]") do
    insert(clone, tonumber(source_num))
  end
  for k, v in pairs(delta) do
    if (v < 0) then
      return true
    end
  end
  return false
end

local function generate_plans_joltage(batteries, batteries_target, buttons)
  local is_battery_equal = evaluate_batteries(batteries, batteries_target)
  local source, delta, target
  local clone_b = batteries
  local is_overload = false
  while (not is_battery_equal) do
    delta, is_overload = delta_batteries(clone_b, batteries_target)
    if (is_overload) then
      break
    end
    source = battery_to_bit(create_source_battery(delta))
    target = battery_to_bit(delta)

    local min_path_count, chosen, is_equal, is_equal_found  = generate_plans(source, target, buttons)
    if (is_equal) then
      apply_battery(clone_b, chosen, buttons)
      is_battery_equal = evaluate_batteries(clone_b, batteries_target)
    else
      is_overload = true
    end
  end
  print("A")
end

local function read_input(filename)
  local line_count = 0
  local target = {}
  local buttons = {}
  local batteries = {}
  local batteries_source = {}
  local source = {}
  local source_count = {}

  for line in rlines(filename) do
    line_count = line_count + 1
    for num in line:gmatch("[^ ]+") do
      if (get_one(num, 1) == "[") then
        source[line_count] = {}
        target[line_count] = {}
        local bit_string = {}
        local bit_string_source = {}
        for i = 0, #num - 3 do
          if get_one(num, i+ 2) == "#" then
            bit_string[i + 1] = "1"
          else
            bit_string[i + 1] = "0"
          end
          bit_string_source[i + 1] = "0"
        end
        target[line_count] = concat(bit_string, "<")
        source[line_count] = concat(bit_string_source, "<")
        source_count[line_count] = #num - 2
      elseif (get_one(num, 1)) == "(" then
        if (buttons[line_count] == nil) then
          buttons[line_count] = {}
        end
        local button_effects = {}
        for effect in num:gmatch("[%d]+") do
          table.insert(button_effects, tonumber(effect))
        end
        local temp = {}
        for i = 1, source_count[line_count] do
          insert(temp, 0)
        end
        for idx, effect in pairs(button_effects) do
          temp[effect + 1] = 1
        end
        table.insert(buttons[line_count], concat(temp, "<"))
      elseif (get_one(num, 1)) == "{" then
        if (batteries[line_count] == nil) then
          batteries[line_count] = {}
        end
        local battery_powers = {}
        local battery_source = {}
        for effect in num:gmatch("[%d]+") do
          table.insert(battery_powers, effect)
          table.insert(battery_source, "0")
        end
        batteries[line_count] = concat(battery_powers, "<")
        batteries_source[line_count] = concat(battery_source, "<")
      else
      end
    end
  end
  return source, target, buttons, batteries, batteries_source, source_count
end

local function q1()
  local filename = "input.txt"
  local total = 0
  local plans, min_path_count, chosen, is_equal, is_equal_found

  local sources, targets, buttons, batteries, batteries_sources, sources_count = read_input(filename)
  for sid = 1, #sources do
    min_path_count, chosen, is_equal, is_equal_found = generate_plans(sources[sid], targets[sid], buttons[sid])
    if (min_path_count) then
      if (is_equal or is_equal_found) then
        total = total + min_path_count
      end
    end
    print(sid, min_path_count, is_equal, is_equal_found, chosen and chosen or "")
  end
  return total
end

local function q2()
  local filename = "sample.txt"
  local total = 0
  local plans, min_path_count, chosen, is_equal, is_equal_found

  local sources, targets, buttons, batteries, batteries_sources, sources_count = read_input(filename)
  for sid = 1, #sources do
    min_path_count, chosen, is_equal, is_equal_found = generate_plans_joltage(batteries_sources[sid], batteries[sid], buttons[sid])
    if (min_path_count) then
      if (is_equal or is_equal_found) then
        total = total + min_path_count
      end
    end
    print(sid, min_path_count, is_equal, is_equal_found, chosen and concat(chosen, "<"))
  end
  return total
end

print(q2())
