local open = io.open
local concat = table.concat
local rlines = io.lines
local insert = table.insert
local tonumber = tonumber
local sub = string.sub


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

local function split(input, pattern, func)
  for data in input:gmatch(pattern) do
    func(data)
  end
end

local function is_in_range(target, min, max)
  return min <= target and target <= max
end

local function is_in_group_range(group, t_min, t_max)
  for min, max in pairs(group) do
    -- t_min  -- t_max  -- min    -- max
    if (tonumber(t_max) < tonumber(min)) then
      if (tonumber(t_max) + 1 == tonumber(min)) then

        print("AAAAAAAA", t_min, t_max, min, max)
        return min, t_min, max
      else

      end
    -- min    -- max    -- t_min  -- t_max
    elseif (tonumber(t_min) > tonumber(max)) then
      if (tonumber(t_min) - 1 == tonumber(max)) then
        print("AAAAAAA1", min, max, t_min, t_max)
        return min, min, t_max
      else

      end
    elseif (tonumber(t_min) <= tonumber(min)) then
      -- t_min  -- min    -- t_max  -- max
      if (tonumber(t_max) <= tonumber(max)) then
        return min, t_min, max
      -- t_min  -- min    -- max    -- t_max
      elseif (tonumber(t_max) >= tonumber(max)) then
        return min, t_min, t_max
      else
        print("BBBB", min, max, t_min, t_max)
      end
    elseif (tonumber(t_min) >= tonumber(min)) then
      -- min    -- t_min    -- max  -- t_max
      if (tonumber(t_max) >= tonumber(max)) then
        return min, min, t_max
      -- min    -- t_min  -- t_max  -- max
      elseif (tonumber(t_max) <= tonumber(max)) then
        return min, min, max
      else
        print("AAAAA", min, max, t_min, t_max)
      end
    else
      print("CCCCC", min, max, t_min, t_max)
    end
  end
end

local function is_min_need_update(t_min, t_max, min, max)
  return t_min < min and t_max >= min
end

local function q1()
  local collision_ranges = {}
  local read_phase = 1
  local pattern_dash = "[^-]+"
  local total_count = 0
  local all_count = 0

  lines_from("input.txt", function(id_txt, txt)
    if(txt == "") then
      read_phase = 2
    else
      if (read_phase == 1) then
        local min, max
        split(txt, pattern_dash, function (num_input)
          if (min == nil) then
            min = tonumber(num_input)
          else
            max = tonumber(num_input)
          end
        end)
        if (collision_ranges[min]) then
          if (collision_ranges[min] < max) then
            collision_ranges[min] = max
          end
        else
          collision_ranges[min] = max
        end
      else
        all_count = all_count + 1
        for k, v in pairs(collision_ranges) do
          if is_in_range(tonumber(txt), k, v) then
            total_count = total_count + 1
            break
          end
        end
      end
    end
  end)

  return total_count, all_count
end

local function q2()
  local merge_collision = nil
  local read_phase = 1
  local pattern_dash = "[^-]+"
  local total_count = 0
  local lowest_min = nil
  local highest_max = nil

  local point_collision = {}
  local point_count = 0

  lines_from("input.txt", function(id_txt, txt)
    if(txt == "") then
      read_phase = 2
    else
      if (read_phase == 1) then
        local min, max
        split(txt, pattern_dash, function (num_input)
          if (min == nil) then
            min = (num_input)
          else
            max = (num_input)
          end
        end)

        local count = tonumber(max) - tonumber(min) + 1
        if (count == 1) then
          point_count = point_count + 1
          point_collision[min] = max
        end

        if (lowest_min) then
          if (tonumber(lowest_min) > tonumber(min)) then
            lowest_min = min
          end
        else
          lowest_min = min
        end

        if (highest_max) then
          if (tonumber(highest_max) < tonumber(max)) then
            highest_max = max
          end
        else
          highest_max = max
        end

        -- print(
        --   string.format("%.f", min)
        -- )
        -- print(
        --   string.format("%.f", max)
        -- )

        if (merge_collision == nil) then
          merge_collision = {}
          merge_collision[min] = max
        else
          local key, new_min, new_max
          key, new_min, new_max = is_in_group_range(merge_collision, min, max)
          if (key) then
            if (merge_collision[key] ~= new_max or key ~= new_min) then
              merge_collision[key] = nil
              merge_collision[new_min] = new_max
            else
              if not (key == new_min and merge_collision[key] == new_max) then
                print("ZZZZZZ", key, merge_collision[key], new_min, new_max, min, max)
              else

              end
            end

            for old_min, old_max in pairs(merge_collision) do
              key, new_min, new_max = is_in_group_range(merge_collision, old_min, old_max)
              if (key) then
                if (merge_collision[key] ~= new_max or key ~= new_min) then
                  merge_collision[key] = nil
                  merge_collision[new_min] = new_max
                else
                  if not (key == new_min and merge_collision[key] == new_max) then
                    print("FFFFFFF", min, max, new_min, new_max)
                  else

                  end
                end
              else
                print("DDDDDDD")
              end
            end
          else
            merge_collision[min] = max
          end
        end

      end
    end
  end)

  local pre_overflow = {}

  if (merge_collision) then
    for k, v in pairs(merge_collision) do
      if (v ~= k) then
        if (total_count + (tonumber(v) - tonumber(k) + 1) < 0) then
          insert(pre_overflow, total_count)
          total_count = (tonumber(v) - tonumber(k) + 1)
          print("overflow : ", total_count, v, k, (tonumber(v) - tonumber(k) + 1), total_count + (tonumber(v) - tonumber(k) + 1))
        else
          print("count : ", v, k, (tonumber(v) - tonumber(k) + 1))
          total_count = total_count + (tonumber(v) - tonumber(k) + 1)
        end
      else
        local key, new_min, new_max
        key, new_min, new_max = is_in_group_range(merge_collision, k, v)
        if (key) then
          print("ABCD", key, new_min, new_max)
        else
          print("DEFG", key, new_min, new_max)
        end
      end
    end
  end

  -- local _p = 0
  -- local _t = 0

  -- if (merge_collision) then
  --   if (point_collision) then

  --     for point, _ in pairs(point_collision) do
  --       _t = _t + 1
  --       -- for check_min, check_max in pairs(merge_collision) do
  --       --   if (check_min ~= point and check_max ~= point) then
  --       --     if (is_in_range(point, check_min, check_max)) then
  --       --       point_collision[point] = nil
  --       --       -- _p = _p + 1
  --       --     end
  --       --   end
  --       -- end
  --     end
  --   end

  --   for min, max in pairs(merge_collision) do
  --     if (min ~= max) then
  --       total_count = total_count + (max - min + 1)
  --     else
  --       for check_min, check_max in pairs(merge_collision) do
  --         if (check_min ~= min) then
  --           if (is_in_range(min, check_min, check_max)) then

  --           else
  --             _p = _p + 1
  --             break
  --           end
  --         end
  --       end
  --     end
  --   end
  -- end

  -- print(_p, _t)
  -- for _, v in pairs(merge_collision) do
  --   total_count = total_count + (v.max - v.min + 1)
  -- end

  -- print(
  --   string.format("%.f", lowest_min),
  --   string.format("%.f", highest_max),
  --   string.format("%.f", highest_max - lowest_min + 1)
  -- )
  print(string.format("%.f", tonumber(highest_max) - tonumber(lowest_min) + 1))
  print(point_count)

  for k, v in pairs(pre_overflow) do
    print("overflow : ", string.format("%.f",v))
  end

  return total_count
end

print(string.format("%.f", q2()))
