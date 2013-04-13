local e={}
local t=fs.combine(_INSTALL_PATH,'ect/log')
if not fs.exists(t)then
fs.makeDir(t)
end
local a={}
local function o(e)
local t=fs.open(e,'a')
for a,e in pairs(a[e])do
t.writeLine(e)
end
t.close()
a[e]=nil
end
function e.flush(i)
if not i then
for e,t in pairs(util.shcopy(a))do
o(e)
end
else
local e=fs.combine(t,i..'.log')
o(e)
end
end
e.instant=false
function e.append(n,i)
local t=fs.combine(t,n..'.log')
a[t]=a[t]or{}
table.insert(a[t],i)
if e.instant==true then
o(t)
end
end
function e.reset(e)
if e then
fs.open(fs.combine(t,e..'.log'),'w').close()
else
fs.delete(t)
fs.makeDir(t)
end
end
log.storelogger=function(a,o,t)
e.append(a,t)
e.append('log',t)
end
return e