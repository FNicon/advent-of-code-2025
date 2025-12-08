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

local function q1()
  local filename = "input.txt"
  local line_count = 0
  local input_raw = {}
  local total = 0
  local stream_idx = {}
  for line in rlines(filename) do
    line_count = line_count + 1
    if (line_count == 1) then
      insert(stream_idx, find_idx(line, "[S]"))
    else
      local check_idx = 1
      local is_loop = true
      local split_idx
      local split_idx_next
      while (check_idx <= #line and is_loop) do
        split_idx = find(line, "^", check_idx, true)
        if (split_idx) then
          split_idx_next = find(line, "^", split_idx + 1, true) or (#line + 1)
          if (split_idx) then
            local candidate = {}
            for key, stream in pairs(stream_idx) do
              if (stream == split_idx) then
                candidate[key] = {split_idx - 1, split_idx + 1}

                total = total + 1
              end
            end
            for key, cand in pairs(candidate) do
              stream_idx[key] = nil
              stream_idx[cand[1]] = cand[1]
              stream_idx[cand[2]] = cand[2]
            end
          end
        else
          is_loop = false
        end
        check_idx = split_idx_next or (check_idx + 1)
      end
    end
  end

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

print(q2())
