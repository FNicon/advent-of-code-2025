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

local function calculate_distance(pos1, pos2)
  return math.sqrt(
    (pos1[1] - pos2[1])^2 +
    (pos1[2] - pos2[2])^2
  )
end

local function calculate_area(pos1, pos2)
  return
    (math.abs(pos1[1] - pos2[1]) + 1) *
    (math.abs(pos1[2] - pos2[2]) + 1)
end

local function get_key(node1, node2)
  return min(node1, node2), max(node1, node2)
end

local function update_min_distance(check_distance, current_min_distance, prev_min_distance)
  local is_need_update = false
  if (current_min_distance) then
    if (prev_min_distance) then
      if (check_distance > prev_min_distance) then
        if (current_min_distance > check_distance) then
          current_min_distance = check_distance
          is_need_update = true
        else

        end
      else

      end
    else
      if (current_min_distance > check_distance) then
        current_min_distance = check_distance
        is_need_update = true
      else

      end
    end
  else
    if (prev_min_distance) then
      if (check_distance > prev_min_distance) then
        current_min_distance = check_distance
        is_need_update = true
      else

      end
    else
      current_min_distance = check_distance
      is_need_update = true
    end
  end
  return current_min_distance, is_need_update
end

local function update_max_distance(check_distance, current_max_distance, prev_max_distance)
  local is_need_update = false
  if (current_max_distance) then
    if (prev_max_distance) then
      if (check_distance < prev_max_distance) then
        if (current_max_distance < check_distance) then
          current_max_distance = check_distance
          is_need_update = true
        else

        end
      else

      end
    else
      if (current_max_distance < check_distance) then
        current_max_distance = check_distance
        is_need_update = true
      else

      end
    end
  else
    if (prev_max_distance) then
      if (check_distance < prev_max_distance) then
        current_max_distance = check_distance
        is_need_update = true
      else

      end
    else
      current_max_distance = check_distance
      is_need_update = true
    end
  end
  return current_max_distance, is_need_update
end


local function search_pair(pos_tbl, tbl_calc, prev_max_calc)
  local _tbl_calc = tbl_calc or {}
  local max_calc
  local is_max_need_update = false
  local pair_key
  for k, pos1 in pairs(pos_tbl) do
    for l, pos2 in pairs(pos_tbl) do
      if (k ~= l) then
        local key1, key2 = get_key(k, l)
        local check_distance
        if (_tbl_calc[key1]) then
          if (_tbl_calc[key1][key2]) then
            check_distance = _tbl_calc[key1][key2]
          else
            check_distance = calculate_area(pos1, pos2)
            _tbl_calc[key1][key2] = check_distance
          end
        else
          check_distance = calculate_area(pos1, pos2)
          _tbl_calc[key1] = {}
          _tbl_calc[key1][key2] = check_distance
        end

        max_calc, is_max_need_update = update_max_distance(check_distance, max_calc, prev_max_calc)
        if (is_max_need_update) then
          pair_key = {key1, key2}
        end
      end
    end
  end
  return pos_tbl, _tbl_calc, pair_key, prev_max_calc
end

local function search_pair2(pos_tbl, tbl_calc, prev_max_calc)
  local _tbl_calc = tbl_calc or {}
  local max_calc
  local is_max_need_update = false
  local pair_key
  local calc_key = {}
  for k, pos1 in pairs(pos_tbl) do
    for l, pos2 in pairs(pos_tbl) do
      if (k ~= l) then
        local key1, key2 = get_key(k, l)
        local check_distance
        if (_tbl_calc[key1]) then
          if (_tbl_calc[key1][key2]) then
            check_distance = _tbl_calc[key1][key2]
          else
            check_distance = calculate_area(pos1, pos2)
            _tbl_calc[key1][key2] = check_distance
          end
        else
          check_distance = calculate_area(pos1, pos2)
          _tbl_calc[key1] = {}
          _tbl_calc[key1][key2] = check_distance
        end

        max_calc, is_max_need_update = update_max_distance(check_distance, max_calc, prev_max_calc)
        if (is_max_need_update) then
          pair_key = {key1, key2}
        end
      end
    end
  end
  for k, v in pairs(_tbl_calc) do
    for l, w in pairs(v) do
      local p1, p2 = get_key(k, l)
      if (p1 <= 249 and p2 == 249) then
        if (w < 1658952126 and w > 1482564371) then
          if (calc_key[w] == nil) then
            calc_key[w] = { [1] = {k, l} }
          else
            table.insert(calc_key[w], {k, l})
          end
        end
      elseif (p1 == 250 and p2 >= 250 and p1 <= 495 and p2 <= 495) then
        if (w < 1658952126 and w > 1482564371) then
          if (calc_key[w] == nil) then
            calc_key[w] = { [1] = {k, l} }
          else
            table.insert(calc_key[w], {k, l})
          end
        end
      end
    end
  end
  return pos_tbl, _tbl_calc, pair_key, max_calc
end

local function is_has(tbl1, tbl2)
  for k, v in pairs(tbl1) do
    for l, w in pairs(tbl2) do
      if (v == w) then
        return true
      end
    end
  end
  return false
end

local function get_has(tbl1, tbl2)
  for k, v in pairs(tbl1) do
    for l, w in pairs(tbl2) do
      if (v == w) then
        return v
      end
    end
  end
  return nil
end

local function get_diff(tbl1, tbl2)
  local copy = {}
  for k, v in pairs(tbl2) do
    copy[k] = v
  end
  for k, v in pairs(tbl1) do
    for l, w in pairs(tbl2) do
      if (v == w) then
        copy[l] = nil
      end
    end
  end
  local result
  for k, v in pairs(copy) do
    if (v) then
      result = v
    end
  end
  return result
end

local function is_dict_has(dict, pair)
  for k, v in pairs(dict) do
    if (k == pair[1] or k == pair[2]) then
      return k
    end
  end
  return nil
end

local function clone_pair(pair)
  local temp = {}
  for k, v in pairs(pair) do
    temp[k] = v
  end
  return temp
end

local function clone_dict(dict)
  local temp = {}
  for k, v in pairs(dict) do
    local nodes = {}
    for l, w in pairs(v) do
      nodes[l] = w
    end
    temp[k] = nodes
  end
  return temp
end

local function get_dict_diff(dict, pair)
  local clone = clone_pair(pair)
  for k, v in pairs(pair) do
    for l, w in pairs(dict) do
      if (w) then
        if (v == l) then
          clone[k] = nil
        end
      end
    end
  end
  return clone
end

local function create_circuit(circuit, pair_key)
  local temp = {}
  if (circuit) then
    local candidate_update = {}
    local candidate_new = {}
    local update_count = 0
    local new_count = 0
    for k, v in pairs(circuit) do
      local found_node = is_dict_has(v, pair_key)
      if (found_node) then
        local diff = get_dict_diff(v, pair_key)
        for l, w in pairs(diff) do
          if (w) then
            candidate_update[k] = {[w] = k}
            update_count = update_count + 1
          end
        end
        -- print("Found Same Node", found_node, k, v)
      else
        candidate_new[k] = {
          [pair_key[1]] = pair_key[2],
          [pair_key[2]] = pair_key[1]
        }
        new_count = new_count + 1
        -- print("Not found", found_node, k, v)
      end
      -- if (is_has(v, pair_key)) then
      --   candidate_update[k] = get_diff(v, pair_key)
      --   update_count = update_count + ((candidate_update[k] ~= nil and 1) or 0)
      -- else
      --   new_count = new_count + 1
      --   candidate_new[k] = pair_key
      -- end
    end
    if (update_count > 0) then
      for k, v in pairs(candidate_update) do
        for l, w in pairs(v) do
          circuit[k][l] = w
        end
      end
    end
    if (new_count > 0) then
      for k, v in pairs(candidate_new) do
        local is_same_found = false
        for l, w in pairs(circuit) do
          if (k ~= l) then
            local found_node = is_dict_has(w, pair_key)
            is_same_found = found_node ~= nil
          end
        end
        if not is_same_found and update_count == 0 then
          insert(circuit, v)
        end
        -- for l, w in pairs(v) do
        --   circuit[k][l] = w
        -- end
      end
      -- insert(circuit, pair_key)
    end
  else
    insert(temp, {
      [pair_key[1]] = pair_key[2],
      [pair_key[2]] = pair_key[1]
    })
  end
  return circuit or temp
end

local function clone_graph(graph)
  local clone = {}
  for index, vertex in pairs(graph) do
    clone[index] = {}
    for node_start, node_end in pairs(vertex) do
      clone[index][node_start] = node_end
    end
  end
  return clone
end

local function merge_graph(graph)
  local clone = clone_graph(graph)
  for index, vertex in pairs(graph) do
    for index_clone, vertex_clone in pairs(clone) do
      if (index ~= index_clone) then
        for node_start, node_end in pairs(vertex) do
          for node_start_clone, node_end_clone in pairs(vertex_clone) do
            if (node_start == node_start_clone) then
              if (node_start_clone ~= node_end_clone and node_start ~= node_end) then
                graph[index][node_start_clone] = node_end_clone
                graph[index][node_end_clone] = node_start_clone
                graph[index_clone][node_start_clone] = nil
                graph[index_clone][node_end_clone] = nil
                clone[index_clone][node_start_clone] = nil
                clone[index_clone][node_end_clone] = nil
              else
                graph[index][node_start] = nil
              end
            end
          end
        end
      end
    end
  end
  return graph
end

local function connect_till_n(pos_tbl, n)
  local pair_key
  local prev_min_distance
  local tbl_distance = {}
  local new_pos_tbl = {}
  for k, v in pairs(pos_tbl) do
    new_pos_tbl[k] = {}
    for l, w in pairs(v) do
      new_pos_tbl[k][l] = w
    end
  end
  local circuit
  -- local links = io.open ("link.json", "w+")
  local nodes = io.open ("node.json", "w+")
  -- if (links ~= nil) then
  --   links:write("[");
  -- end
  if nodes ~= nil then
    nodes:write("[");
  end
  local unique_node = {}
  for i = 1, n do
    new_pos_tbl, tbl_distance, pair_key, prev_min_distance = search_pair(new_pos_tbl, tbl_distance, prev_min_distance)
    if (pair_key) then
      circuit = create_circuit(circuit, pair_key)
    end
    -- if (links ~= nil) then
    --   links:write(string.format('{"source":"%s","target":"%s","value":2},\n', pair_key[1], pair_key[2]))
    -- end
    if (nodes ~= nil) then
      unique_node[pair_key[1]] = 1
      unique_node[pair_key[2]] = 1
      -- nodes:write(string.format('{"id":"%s", "group":"Cited Works","radius":1, "citing_patents_count":1},\n', pair_key[1]))
      -- nodes:write(string.format('{"id":"%s", "group":"Cited Works","radius":1, "citing_patents_count":1},\n', pair_key[2]))
    end

    -- print(i, "node1(xyz):",
    --   pair_key[1],
    --   pos_tbl[pair_key[1]][1], pos_tbl[pair_key[1]][2], pos_tbl[pair_key[1]][3],
    --   "node2(xyz):",
    --   pair_key[2],
    --   pos_tbl[pair_key[2]][1], pos_tbl[pair_key[2]][2], pos_tbl[pair_key[2]][3]
    --   -- prev_min_distance
    -- )
  end
  -- if (links ~= nil) then
  --   links:write("]");
  -- end
  if nodes ~= nil then
    for k, v in pairs(unique_node) do
      nodes:write(string.format('{"id":"%s", "group":"Cited Works","radius":1, "citing_patents_count":1},\n', k))
    end
    nodes:write("]");
  end
  -- circuit = merge_graph(circuit)
  local size = {}
  for k, v in pairs(circuit) do
    local count = 0
    for l, w in pairs (v) do
      count = count + 1
    end
    size[k] = count
  end
  table.sort(size, function(a, b)
    return a > b
  end)
  return size[1] * size[2] * size[3]
end

local function connect_till_all(pos_tbl, all_node_count)
  local pair_key
  local prev_max_distance
  local tbl_distance = {}
  local new_pos_tbl = {}
  for k, v in pairs(pos_tbl) do
    new_pos_tbl[k] = {}
    for l, w in pairs(v) do
      new_pos_tbl[k][l] = w
    end
  end
  new_pos_tbl, tbl_distance, pair_key, prev_max_distance = search_pair(new_pos_tbl, tbl_distance, prev_max_distance)
  return prev_max_distance
end

local function generate_bound(pos_tbl)
  local bound_tbl = {}
  for k, p1 in pairs(pos_tbl) do
    for l, p2 in pairs(pos_tbl) do
      if (k ~= l) then
        local x1 = p1[1]
        local y1 = p1[2]
        local x2 = p2[1]
        local y2 = p2[2]

        if (x1 == x2) then
          if (bound_tbl[k]) then
            table.insert(bound_tbl[k], l)
          else
            bound_tbl[k] = {l}
          end
        elseif (y1 == y2) then
          if (bound_tbl[k]) then
            table.insert(bound_tbl[k], l)
          else
            bound_tbl[k] = {l}
          end

        end
      end
    end
  end
  return bound_tbl
end

local function connect_till_all2(pos_tbl, all_node_count)
  local pair_key
  local prev_max_distance
  local tbl_distance = {}
  local new_pos_tbl = {}
  for k, v in pairs(pos_tbl) do
    new_pos_tbl[k] = {}
    for l, w in pairs(v) do
      new_pos_tbl[k][l] = w
    end
  end
  local bound_table = generate_bound(pos_tbl)
  new_pos_tbl, tbl_distance, pair_key, prev_max_distance = search_pair2(new_pos_tbl, tbl_distance, prev_max_distance)
  return prev_max_distance
end


local function q1()
  local filename = "input.txt"
  local line_count = 0
  local total = 0
  local box_pos = {}
  for line in rlines(filename) do
    line_count = line_count + 1
    local col_count = 1
    local position = {}
    for num in line:gmatch("[^,]+") do
      position[col_count] = tonumber(num)
      col_count = col_count + 1
    end
    box_pos[line_count] = position
  end

  total = connect_till_all(box_pos, 1)

  return total
end

local function q2()
  local filename = "input.txt"
  local line_count = 0
  local total = 0
  local box_pos = {}

  for line in rlines(filename) do
    line_count = line_count + 1
    local col_count = 1
    local position = {}
    for num in line:gmatch("[^,]+") do
      position[col_count] = tonumber(num)
      col_count = col_count + 1
    end
    box_pos[line_count] = position
  end

  -- local tsv = io.open ("output.tsv", "w+")
  -- if (tsv ~= nil) then
  --   tsv:write("eruptions\twaiting\n");
  --   for k, p1 in pairs(box_pos) do
  --     tsv:write(string.format("%s\t%s\n", p1[1], p1[2]))
  --   end
  -- end

  local bound = generate_bound(box_pos)
  -- for k, v in pairs(bound) do
  --   if (#v > 2) then
  --     -- print(k, v)
  --   end
  --   if (k == 1) then
  --     for i=#v, 1, -1 do
  --       if (v[i] ~= 496 and v[i] ~= 2) then
  --         -- table.remove(v, i)
  --       end
  --     end
  --   elseif (k == 123) then
  --     for i=#v, 1, -1 do
  --       if (v[i] ~= 122 and v[i] ~= 124) then
  --         -- table.remove(v, i)
  --       end
  --     end
  --   elseif (k == 124) then
  --     for i=#v, 1, -1 do
  --       if (v[i] ~= 123 and v[i] ~= 125) then
  --         -- table.remove(v, i)
  --       end
  --     end
  --   elseif (k == 248) then
  --     for i=#v, 1, -1 do
  --       if (v[i] ~= 247 and v[i] ~= 249) then
  --         -- table.remove(v, i)
  --       end
  --     end
  --   elseif (k == 249) then
  --     for i=#v, 1, -1 do
  --       if (v[i] ~= 248 and v[i] ~= 250) then
  --         -- table.remove(v, i)
  --       end
  --     end
  --   elseif (k == 375) then
  --     for i=#v, 1, -1 do
  --       if (v[i] ~= 374 and v[i] ~= 376) then
  --         -- table.remove(v, i)
  --       end
  --     end
  --   elseif (k == 376) then
  --     for i=#v, 1, -1 do
  --       if (v[i] ~= 375 and v[i] ~= 377) then
  --         -- table.remove(v, i)
  --       end
  --     end
  --   elseif (k == 496) then
  --     for i=#v, 1, -1 do
  --       if (v[i] ~= 1 and v[i] ~= 495) then
  --         -- table.remove(v, i)
  --       end
  --     end
  --   end
  -- end
  -- local links = io.open ("link.json", "w+")
  -- if (links ~= nil) then
  --   links:write("[\n");
  --   for p1, v in pairs(bound) do
  --     for l, p2 in pairs(v) do
  --       links:write(string.format('{"source":"%s","target":"%s", "value":2},\n', p1, p2))
  --     end
  --   end
  --   links:write("]");
  -- end

  -- local nodes = io.open ("node.json", "w+")
  -- if nodes ~= nil then
  --   nodes:write("[\n");
  --   for k, v in pairs(box_pos) do
  --     nodes:write(string.format('{"id":"%s", "radius":1, "group":"A", "x":%d, "y": %d},\n', k, v[1], v[2]))
  --   end
  --   nodes:write("]");
  -- end
  total = connect_till_all2(box_pos, 1)

  return total
end



print(q2())
