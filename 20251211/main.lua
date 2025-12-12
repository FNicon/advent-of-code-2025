local rlines = io.lines
local insert = table.insert
local find = string.find
local gsub = string.gsub
local concat = table.concat
local format = string.format

local function is_traversed(path, target)
  for node in path:gmatch("[^ ]+") do
    if (node == target) then
      return true
    end
  end
  return false
end

local function get_last_node(path)
  local last_node
  local deep_count = 0
  for node in path:gmatch("[^ ]+") do
    last_node = node
    deep_count = deep_count + 1
  end
  return last_node, deep_count
end

local function get_previous_path(path, deep_count)
  local count = 1
  local temp = {}
  for node in path:gmatch("[^ ]+") do
    if (deep_count > count) then
      insert(temp, node)
    end
    count = count + 1
  end
  return concat(temp, " ")
end

local function diverge_track(current, choices, target)
  local tracked = {}
  if (choices) then
    for choice_id, node in pairs(choices) do
      if (node == target) then
        local path = format("%s %s", current, node)
        if (not is_traversed(current, node)) then
          tracked[path] = 1
        else
          print(path)
        end
      else
        local path = format("%s %s", current, node)
        if (not is_traversed(current, node)) then
          tracked[path] = 0
        else
          print(path)
        end
      end
    end
  end
  return tracked
end

local function is_node_in_targets(node, targets)
  for t, v in pairs(targets) do
    if (node == v) then
      return true
    end
  end
  return false
end

local function diverge_tracks(current, choices, targets)
  local tracked = {}
  for choice_id, node in pairs(choices) do
    if (is_node_in_targets(node, targets)) then
      local path = format("%s %s", current, node)
      if (not is_traversed(current, node)) then
        tracked[path] = 1
      else
        print(path)
      end
    else
      local path = format("%s %s", current, node)
      if (not is_traversed(current, node)) then
        tracked[path] = 0
      else
        print(path)
      end
    end
  end
  return tracked
end

local function merge_tracked(tracked, new_tracked)
  local temp = {}
  local to_delete = {}
  for diverged_id, diverged_path in pairs(new_tracked) do
    for path, reach_target in pairs(diverged_path) do
      local last_node, deep_count = get_last_node(path)
      local prev_path = get_previous_path(path, deep_count)
      for old_path, old_reach_target in pairs(tracked) do
        if (old_path == prev_path) then
          if (to_delete[old_path] == nil) then
            to_delete[old_path] = old_reach_target
          else
            to_delete[old_path] = old_reach_target
          end
        end
      end
      temp[path] = reach_target
    end
  end
  for old_path, old_reach_target in pairs(tracked) do
    if (not to_delete[old_path]) then
      temp[old_path] = old_reach_target
    end
  end
  return temp
end

local function is_same_keys(track1, track2)
  for k, v in pairs(track1) do
    if (track2[k]) then
      if (track2[k] ~= v) then
        return false
      end
    else
      return false
    end
  end
  return true
end

local function clone_track(track)
  local temp = {}
  for k, v in pairs(track) do
    temp[k] = v
  end
  return temp
end

local function count_found_target(track)
  local count = 0
  for k, v in pairs(track) do
    count = count + v
  end
  return count
end

local function traverse(graph, current, target)
  local tracked = {}
  local choices = graph[current]
  local new_current = current
  local new_tracked = {}
  local clone_tracked = {}
  local to_check_track

  tracked = diverge_track(new_current, choices, target)
  while (not is_same_keys(tracked, clone_tracked)) do
    for track_path, reach_target in pairs(tracked) do
      if (reach_target == 0) then
        local last_node, deep_count  = get_last_node(track_path)
        local current_choices = graph[last_node]
        to_check_track = diverge_track(track_path, current_choices, target)
        insert(new_tracked, to_check_track)
      end
    end
    clone_tracked = clone_track(tracked)
    tracked = merge_tracked(tracked, new_tracked)
  end
  return tracked, count_found_target(tracked)
end

local function is_via(tracked, via)
  local via_count = {}
  local is_via_found = false
  for track_path, reach_target in pairs(tracked) do
    if (reach_target == 0) then
      via_count[track_path] = 0
      for via_id, via_path in pairs(via) do
        if (is_traversed(track_path, via_path)) then
          via_count[track_path] = via_count[track_path] + 1
          is_via_found = true
        end
      end
    else
      via_count[track_path] = 0
      for via_id, via_path in pairs(via) do
        if (is_traversed(track_path, via_path)) then
          via_count[track_path] = via_count[track_path] + 1
          is_via_found = true
        end
      end
    end
  end
  return via_count, is_via_found
end

-- local function traverse_via(graph, current, via, target)
--   local tracked = {}
--   local choices = graph[current]
--   local new_current = current
--   local new_tracked = {}
--   local clone_tracked = {}
--   local to_check_track
--   local is_focus_on_via = false
--   local via_count_path, is_via_found

--   tracked = diverge_track(new_current, choices, target)
--   while (not is_same_keys(tracked, clone_tracked)) do
--     via_count_path, is_via_found = is_via(tracked, via)
--     if (is_via_found or is_focus_on_via) then
--       is_focus_on_via = true
--       for via_path, via_count in pairs(via_count_path) do
--         if (via_count > 0) then
--           -- for track_path, reach_target in pairs(tracked) do
--             if (reach_target == 0) then
--               local last_node, deep_count  = get_last_node(via_path)
--               local current_choices = graph[last_node]
--               to_check_track = diverge_track(via_path, current_choices, target)
--               insert(new_tracked, to_check_track)
--               print(deep_count, via_path)
--             end
--           -- end
--           clone_tracked = clone_track(tracked)
--           tracked = merge_tracked(tracked, new_tracked)
--         else
--           print(via_count, via_path)
--         end
--       end
--     else
--       for track_path, reach_target in pairs(tracked) do
--         if (reach_target == 0) then
--           local last_node, deep_count  = get_last_node(track_path)
--           local current_choices = graph[last_node]
--           to_check_track = diverge_track(track_path, current_choices, target)
--           insert(new_tracked, to_check_track)
--           print(deep_count, track_path)
--         end
--       end
--       clone_tracked = clone_track(tracked)
--       tracked = merge_tracked(tracked, new_tracked)
--     end
--   end
--   return tracked, count_found_target(tracked), is_via(tracked, via)
-- end

local function traverse_via(graph, current, targets)
  local tracked = {}
  local choices = graph[current]
  local new_current = current
  local new_tracked = {}
  local clone_tracked = {}
  local to_check_track

  tracked = diverge_tracks(new_current, choices, targets)
  while (not is_same_keys(tracked, clone_tracked)) do
    for track_path, reach_target in pairs(tracked) do
      if (reach_target == 0) then
        local last_node, deep_count  = get_last_node(track_path)
        local current_choices = graph[last_node]
        to_check_track = diverge_tracks(track_path, current_choices, targets)
        insert(new_tracked, to_check_track)
        print(deep_count, track_path)
      end
    end
    clone_tracked = clone_track(tracked)
    tracked = merge_tracked(tracked, new_tracked)
  end
  return tracked, count_found_target(tracked)
end

local function read_input(filename)
  local graph = {}
  local graph_out = {}
  -- graph["out"] = {}
  for line in rlines(filename) do
    local start_node = ""
    for node in line:gmatch("[^ ]+") do
      if (find(node, "[:]")) then
        start_node = gsub(node, ":", "")
        graph[start_node] = {}
      else
        if (node == "out") then
          if (graph_out[node] == nil) then
            graph_out["out"] = {}
          end
          insert(graph_out["out"], start_node)
          -- insert(graph["out"], start_node)
          insert(graph[start_node], "out")
        else
          if (graph_out[node] == nil) then
            graph_out[node] = {}
          end
          insert(graph_out[node], start_node)
          insert(graph[start_node], node)
        end
      end
    end
  end
  return graph, graph_out
end

local function q1()
  local filename = "sample.txt"
  local graph, graph_out = read_input(filename)
  local tracked, track_count = traverse(graph_out, "out", "you")
  return track_count
end

local function get_graph_end(graph, targets)
  local temp = {}
  for start_node, end_nodes in pairs(graph) do
    for end_id, end_node in pairs(end_nodes) do
      for target, t_count in pairs(targets) do
        if (target == end_node) then
          if (temp[start_node] == nil) then
            temp[start_node] = 0
          end
          temp[start_node] = temp[start_node] + 1
        end
      end
    end
  end
  return temp
end

local function q2()
  local filename = "input.txt"
  local graph, graph_out = read_input(filename)
  -- local tracked, track_count = traverse_via(graph, "svr", {"fft", "dac"})
  -- print(tracked, track_count)
  local tracked_fft, track_count_fft = traverse(graph_out, "fft", "svr")
  local tracked_dac, track_count_dac = traverse(graph_out, "dac", "svr")
  local count = 0
  -- for k, v in pairs(via_count) do
  --   if v == 2 then
  --     count = count + 1
  --   end
  -- end
  return count
end

print(q2())
