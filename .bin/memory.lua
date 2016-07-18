#!/usr/bin/env lr
-- Todo: consider using /proc/meminfo instead
local os = { exit = os.exit }
local io = {
   popen = io.popen,
   stdout = io.stdout,
   stderr = io.stderr
}
local string = {
    gsub = string.gsub,
    rep = string.rep
}
local table = { unpack = table.unpack }
local math = { min = math.min }
local tonumber = tonumber
local rawset = rawset

dbg(rawset, _G, "human", true) -- ghetto rig lr -d debug flag to define our var used to determine if we should set -h in free

local input_pattern ={ "%t", "%u", "%f", "%s", "%c", "%a", "%T", "%U", "%F" }
local display =
{   "b", "k", "m", "g",
    "bytes", "kibi", "mebi", "gibi", "tebi", "pebi", -- ^10
             "kilo", "mega", "giga", "tera", "peta"  -- ^12
}

local suffix = {
    "B", "KiB", "MiB", "GiB",
    "B", "KiB", "MiB", "GiB", "TiB", "PiB",
         "KB",  "MB",  "GB",  "TB",  "PB"
}

for i=1, #display do
    display[display[i]] = i
end 

local format = _G.format or arg[1] or ""
local output_format = _G.D or arg[2]

local of_ndx = display[output_format or ""]
local flags = " "


if of_ndx then
    flags=flags..string.rep("-", math.min(#output_format, 2))
    flags=flags..output_format
elseif human then -- Only pass -h if --D is unset because -h in free eats up other format options
    -- dbg(function() flags=flags.."-h" end)
    flags=flags.."-h"
end


local fdesc, err = io.popen("free"..flags, "r")
if not fdesc then
    io.stderr:write("Failed: " .. tostring(err) .. "\n")
    os.exit(1)
end


fdesc:read() -- Discard first line, "l" is default read mode
local mem = fdesc:read()
local swp = fdesc:read()


do  -- Todo: make a module or something for a library of utility functions like this, bind, etc
    local function factory(pos)
        local i=tonumber(pos) and pos-1 or 0
        return (function()
            i=i+1
            return i
        end)
    end
    
    local inc = factory()
    local subfunc
    local capture = "([%d%.]+%a?)"
    
    if of_ndx and human
    then subfunc = function(m) format=string.gsub(format, "%"..input_pattern[inc()], m..suffix[of_ndx]) end
    else subfunc = function(m) format=string.gsub(format, "%"..input_pattern[inc()], m) end
    end

    string.gsub(mem, capture, subfunc)
    if swp then -- They may not have a swap, God knows why
        string.gsub(swp, capture, subfunc)
    end
end

io.stdout:write(format.."\n");
os.exit(fdesc:close())

