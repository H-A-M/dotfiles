#!/usr/bin/env lr
io.stdout:write(table.unpack({string.gsub(_G.str or arg[3] or io.stdin:read("*all"), _G.cap or _G.capture or _G.C or arg[1] or "", _G.rep or _G.replace or _G.R or arg[2] or "")},1,1))

