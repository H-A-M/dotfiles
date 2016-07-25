#! /usr/bin/env lr
local io = {
    popen = io.popen,
    stderr = io.stderr,
    stdout = io.stdout
}
local os = { exit = os.exit }
local string = {
    gsub = string.gsub,
    match = string.match
}

local format = _G.format or arg[1]
local fdesc, err = io.popen("sensors", "r")
if not fdesc then
    io.stderr:write("Failed: " .. tostring(err) .. "\n")
    os.exit(1)
end

local str = fdesc:read("*all")

for n=0, 3 do
    format=string.gsub(format, "%%core"..n, function(s)
        local cap = "(%d+)%.%d+"
        dbg(function() cap="(%d+%.%d+)" end)

        return string.match(str, "Core "..n..":%s*%+"..cap)
    end)
end

for n=1, 2 do
    format=string.gsub(format, "%%fan"..n, function(s)
        return string.match(str, "fan" ..n.. ":%s*(%d+) RPM")
    end)
end

io.stdout:write(format.."\n")
os.exit(0)

