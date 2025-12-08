local open = io.open
local rlines = io.lines
local insert = table.insert

local t = {}

-- http://lua-users.org/wiki/FileInputOutput

-- see if the file exists
function t.file_exists(file)
  local f = open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function t.lines_from(file, func)
  if not t.file_exists(file) then return {} end
  local res = {}
  local rd = rlines(file)
  for line in rd do
    insert(res, line)
    func(#res, line)
  end
  return res
end

return t