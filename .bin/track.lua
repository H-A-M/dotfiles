#!/usr/bin/env lr

local os = { exit = os.exit }
local io = {
   popen = io.popen,
   stdout = io.stdout,
   stderr = io.stderr
}
local string = {
   find = string.find,
   gsub = string.gsub,
   match = string.match
}
local table = { unpack = table.unpack }
local tostring = tostring
local tonumber = tonumber
local select = select
local type = type

function concat(t, ...)
    local n=#t
    for i=1,#{...} do
        t[n+i] = select(i, ...)
    end
    return t
end

local function bind(func, ...)
    local a = {...}
    return function(...)
        return func(table.unpack(concat(a, ...)))
    end
end


local format = _G.format or arg[1] or "%n"
local fdesc, err = io.popen("mpc", "r")
if not fdesc then
    io.stderr:write("Failed: " .. tostring(err) .. "\n")
    os.exit(1)
end


local track = fdesc:read()
local status = fdesc:read()
local settings = fdesc:read()


-- Any evaluation done in bind here is acceptable
local patterns = {
    { "%N", function() end, status and track or "no track" },       -- Raw title
    { "%n", (function()                             -- Title without stream prefixes
       if not status then return end
      
       -- remove garbage from stream stations
       local s = track
       s=string.gsub(s, ".+%[SomaFM%]:%s*",      "")
       s=string.gsub(s, "Serve Chilled %- ",     "")
       s=string.gsub(s, "ABSOLUTECHILLOUT: ",    "")
       s=string.gsub(s, "OCEAN RADIO CHILLED: ", "")
       s=string.gsub(s, "MusicArtclub Thessaloniki Athens Greece: ",              "")
       s=string.gsub(s, "The Buzzoutroom%.%.%.Chilled%-out Ambient Downbeats%: ", "")

       return s
    end), "no track" },
    { "%b", bind(string.match, status or "", "^%[(%a+)%]") },                             -- Track status
    { "%B", bind(tostring, string.match(status or "", "^%[playing%]")~=nil) },            -- Track is playing (bool)
    { "%t", bind(string.match, status or "", "(%d+:%d+)/%d+:%d+"), "0:00" },              -- Elapsed time
    { "%T", bind(string.match, status or "", "%d+:%d+/(%d+:%d+)"), "0:00" },              -- Total time
    { "%p", bind(string.match, status or "", "%((%d+%%)%)"), "0%" },                      -- Percentage complete

    { "%m", bind(tostring, tonumber(string.match(settings or track, "(%d+)%%") or 1) == 0) },   -- Track is muted (bool)
    { "%v", bind(string.match, settings or track, "(%d+%%)") },                                 -- Volume

    { "%r", bind(tostring, string.match(settings or track, "repeat: (%a+)") ) },   -- Mode: Repeat
    { "%z", bind(tostring, string.match(settings or track, "random: (%a+)") ) },   -- Mode: Random
    { "%y", bind(tostring, string.match(settings or track, "single: (%a+)") ) },   -- Mode: Single
    { "%c", bind(tostring, string.match(settings or track, "consume: (%a+)")) },   -- Mode: Consume

    -- Todo: consider a metatable to set [ "%flag" ] = flag_index then grab and reuse the binds above
    -- { "%R", bind(tostring, string.match(settings or track, "repeat: (%a+)") == "on") },   -- Mode: Repeat (bool)
    -- { "%Z", bind(tostring, string.match(settings or track, "random: (%a+)") == "on") },   -- Mode: Random (bool)
    -- { "%Y", bind(tostring, string.match(settings or track, "single: (%a+)") == "on") },   -- Mode: Single (bool)
    -- { "%C", bind(tostring, string.match(settings or track, "consume: (%a+)") =="on") }    -- Mode: Consume (bool)
}

for i=1, #patterns do
    format = string.gsub(format, "%"..patterns[i][1], function(m)
        local _, t, d = table.unpack(patterns[i])
        return t() or d or ""
    end)
end

io.stdout:write(format.."\n");
os.exit(fdesc:close())

