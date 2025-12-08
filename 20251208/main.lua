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
    (pos1[2] - pos2[2])^2 +
    (pos1[3] - pos2[3])^2
  )
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

local function search_pair(pos_tbl, tbl_distance, prev_min_distance)
  local _tbl_distance = tbl_distance or {}
  -- local new_pos_tbl = {}
  local min_distance
  local is_min_need_update = false
  local pair_key
  for k, pos1 in pairs(pos_tbl) do
    for l, pos2 in pairs(pos_tbl) do
      if (k ~= l) then
        local key1, key2 = get_key(k, l)
        local check_distance
        if (_tbl_distance[key1]) then
          if (_tbl_distance[key1][key2]) then
            check_distance = _tbl_distance[key1][key2]
          else
            check_distance = calculate_distance(pos1, pos2)
            _tbl_distance[key1][key2] = check_distance
          end
        else
          check_distance = calculate_distance(pos1, pos2)
          _tbl_distance[key1] = {}
          _tbl_distance[key1][key2] = check_distance
        end

        min_distance, is_min_need_update = update_min_distance(check_distance, min_distance, prev_min_distance)
        if (is_min_need_update) then
          pair_key = {key1, key2}
        end
      end
    end
  end
  -- for k, v in pairs(pos_tbl) do
  --   if (k ~= pair_key[1] and k ~= pair_key[2]) then
  --     new_pos_tbl[k] = v
  --   end
  -- end
  return pos_tbl, _tbl_distance, pair_key, min_distance
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
  local prev_min_distance
  local tbl_distance = {}
  local new_pos_tbl = {}
  for k, v in pairs(pos_tbl) do
    new_pos_tbl[k] = {}
    for l, w in pairs(v) do
      new_pos_tbl[k][l] = w
    end
  end
  -- local circuit
  -- local links = io.open ("link.json", "w+")
  -- local nodes = io.open ("node.json", "w+")
  -- if (links ~= nil) then
  --   links:write("[");
  -- end
  -- if nodes ~= nil then
  --   nodes:write("[");
  -- end
  local unique_node = {}
  local unique_count = 0
  while unique_count ~= all_node_count do
    new_pos_tbl, tbl_distance, pair_key, prev_min_distance = search_pair(new_pos_tbl, tbl_distance, prev_min_distance)
    -- if (pair_key) then
    --   circuit = create_circuit(circuit, pair_key)
    -- end
    -- if (links ~= nil) then
    --   links:write(string.format('{"source":"%s","target":"%s","value":2},\n', pair_key[1], pair_key[2]))
    -- end
    -- if (nodes ~= nil) then
    unique_node[pair_key[1]] = 1
    unique_node[pair_key[2]] = 1
    --   -- nodes:write(string.format('{"id":"%s", "group":"Cited Works","radius":1, "citing_patents_count":1},\n', pair_key[1]))
    --   -- nodes:write(string.format('{"id":"%s", "group":"Cited Works","radius":1, "citing_patents_count":1},\n', pair_key[2]))
    -- end

    -- print(i, "node1(xyz):",
    --   pair_key[1],
    --   pos_tbl[pair_key[1]][1], pos_tbl[pair_key[1]][2], pos_tbl[pair_key[1]][3],
    --   "node2(xyz):",
    --   pair_key[2],
    --   pos_tbl[pair_key[2]][1], pos_tbl[pair_key[2]][2], pos_tbl[pair_key[2]][3]
    --   -- prev_min_distance
    -- )
    unique_count = 0
    for k, v in pairs(unique_node) do
      unique_count = unique_count + 1
    end
    if (unique_count == all_node_count) then
      print("LAST NODE : ", pair_key[1], pair_key[2], pos_tbl[pair_key[1]][1], pos_tbl[pair_key[2]][1])
    end
    print(unique_count)
  end
  -- if (links ~= nil) then
  --   links:write("]");
  -- end
  -- if nodes ~= nil then
  --   for k, v in pairs(unique_node) do
  --     nodes:write(string.format('{"id":"%s", "group":"Cited Works","radius":1, "citing_patents_count":1},\n', k))
  --   end
  --   nodes:write("]");
  -- end
  -- circuit = merge_graph(circuit)
  local x_mul = pos_tbl[pair_key[1]][1] * pos_tbl[pair_key[2]][1]
  -- local size = {}
  -- for k, v in pairs(circuit) do
  --   local count = 0
  --   for l, w in pairs (v) do
  --     count = count + 1
  --   end
  --   size[k] = count
  -- end
  -- table.sort(size, function(a, b)
  --   return a > b
  -- end)
  return x_mul
end


local function q1()
  local filename = "input.txt"
  local n_count = 1000
  local line_count = 0
  local input_raw = {}
  local total = 0
  local stream_idx = {}
  local junction_box_pos = {}
  for line in rlines(filename) do
    line_count = line_count + 1
    local col_count = 1
    local position = {}
    for num in line:gmatch("[^,]+") do
      position[col_count] = tonumber(num)
      col_count = col_count + 1
    end
    junction_box_pos[line_count] = position
  end

  total = connect_till_all(junction_box_pos, 1000)

  return total
end

local function q2()
  local filename = "input.txt"
  local line_count = 0
  local split_count = 0
  local timeline_count = 0
  local stream_idx = {}
  local original_idx = {}

  for line in rlines(filename) do
    line_count = line_count + 1
    if (line_count == 1) then
      local idx = find_idx(line, "[S]") or 1
      stream_idx[tostring(idx)] = 1
    else
      local check_idx = 1
      local is_loop = true
      local split_idx
      local split_idx_next
      local split_timeline_candidate = {}

      for k, v in pairs(original_idx) do
        original_idx[k] = nil
      end
      for k, v in pairs(stream_idx) do
        original_idx[k] = v
      end
      while (check_idx <= #line and is_loop) do
        split_idx = find(line, "^", check_idx, true)
        if (split_idx) then
          split_idx_next = find(line, "^", split_idx + 1, true) or (#line + 1)
          if (split_idx) then
            local candidate = {}
            for key, _ in pairs(stream_idx) do
              if (key == tostring(split_idx)) then
                candidate[tostring(key)] = {split_idx - 1, split_idx + 1}

                split_count = split_count + 1
              end
            end
            for key, cand in pairs(candidate) do
              stream_idx[tostring(cand[1])] = stream_idx[tostring(key)] + (split_timeline_candidate[tostring(cand[1])] or 0) + (original_idx[tostring(cand[1])] or 0)
              stream_idx[tostring(cand[2])] = stream_idx[tostring(key)] + (split_timeline_candidate[tostring(cand[2])] or 0) + (original_idx[tostring(cand[2])] or 0)

              split_timeline_candidate[tostring(cand[1])] = stream_idx[tostring(key)]
              split_timeline_candidate[tostring(cand[2])] = stream_idx[tostring(key)]
              stream_idx[tostring(key)] = nil
            end
          end
        else
          is_loop = false
        end
        check_idx = split_idx_next or (check_idx + 1)
      end
    end
  end

  for k, v in pairs(stream_idx) do
    timeline_count = timeline_count + v
  end

  return timeline_count
end

print(q1())
