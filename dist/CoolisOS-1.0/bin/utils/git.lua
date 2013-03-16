local o,s,t,h,n={...},nil,nil,"","master"
local l=[[
 github <user> <repo> [path] [remote path] [branch]
 Remote path defaults to the root of the repo.
 Path defaults to the download folder.
 Branch defaults to master.
 If you want to leave an option empty use a dot.
 Example: github johnsmith hello-world . foo
 Everything inside the directory foo will be 
 downloaded to downloads/hello-world/.
  ]]
local d=[[
@blacklistedfile
]]
local r="Github Repo Downloader"
local i={dirs={},files={}}
local e,a=term.getSize()
function printTitle()
local t=2
term.setCursorPos(1,t)
for e=2,e,1 do write("-")end
term.setCursorPos((e-r:len())/2,t+1)
print(r)
for e=2,e,1 do write("-")end
end
function writeCenter(t)
term.clear()
printTitle()
term.setCursorPos((e-t:len())/2-1,a/2-1)
for e=-1,t:len(),1 do write("-")end
term.setCursorPos((e-t:len())/2-1,a/2)
print("|"..t.."|")
term.setCursorPos((e-t:len())/2-1,a/2+1)
for e=-1,t:len(),1 do write("-")end
end
function printUsage()
local t="Press space key to continue"
term.clear()
printTitle()
term.setCursorPos(1,a/2-4)
print(l)
term.setCursorPos((e-t:len())/2,a/2+7)
print(t)
while true do
local t,e=os.pullEvent("key")
if e==57 then
sleep(0)
break
end
end
term.clear()
term.setCursorPos(1,1)
end
function downloadFile(e,a,t)
writeCenter("Downloading File: "..t)
dirPath=e:gmatch('([%w%_%.% %-%+%,%;%:%*%#%=%/]+)/'..t..'$')()
if dirPath~=nil and not fs.isDir(dirPath)then fs.makeDir(dirPath)end
local t=http.get(a)
local e=fs.open(e,"w")
e.write(t.readAll())
e.close()
end
function getGithubContents(e)
local i,o,a,h={},{},{},{}
local e=http.get("https://api.github.com/repos/"..s.."/"..t.."/contents/"..e.."/?ref="..n)
if e then
e=e.readAll()
if e~=nil then
for e in e:gmatch('"type":"(%w+)"')do table.insert(i,e)end
for e in e:gmatch('"path":"([^\"]+)"')do table.insert(o,e)end
for e in e:gmatch('"name":"([^\"]+)"')do table.insert(a,e)end
end
else
writeCenter("Error: Can't resolve URL")
sleep(2)
term.clear()
term.setCursorPos(1,1)
error()
end
return i,o,a
end
function isBlackListed(e)
if d:gmatch("@"..e)()~=nil then
return true
end
end
function downloadManager(e)
local d,e,o=getGithubContents(e)
for a,r in pairs(d)do
if r=="file"then
checkPath=http.get("https://raw.github.com/"..s.."/"..t.."/"..n.."/"..e[a])
if checkPath==nil then
e[a]=e[a].."/"..o[a]
end
local r="downloads/"..t.."/"..e[a]
if h~=""then r=h.."/"..t.."/"..e[a]end
if not i.files[r]and not isBlackListed(e[a])then
i.files[r]={"https://raw.github.com/"..s.."/"..t.."/"..n.."/"..e[a],o[a]}
end
end
end
for a,r in pairs(d)do
if r=="dir"then
local r="downloads/"..t.."/"..e[a]
if h~=""then r=h.."/"..t.."/"..e[a]end
if not i.dirs[r]then
writeCenter("Listing directory: "..o[a])
i.dirs[r]={"https://raw.github.com/"..s.."/"..t.."/"..n.."/"..e[a],o[a]}
downloadManager(e[a])
end
end
end
end
function main(e)
writeCenter("Connecting to Github")
downloadManager(e)
for t,e in pairs(i.files)do
downloadFile(t,e[1],e[2])
end
writeCenter("Download completed")
sleep(2,5)
term.clear()
term.setCursorPos(1,1)
end
function parseInput(r,i,o,e,a)
if e==nil then e=""end
if a~=nil then n=a end
if i==nil then printUsage()
else
s=r
t=i
if o~=nil then h=o end
main(e)
end
end
if not http then
writeCenter("You need to enable the HTTP API!")
sleep(3)
term.clear()
term.setCursorPos(1,1)
else
for e=1,5,1 do
if o[e]=="."then o[e]=nil end
end
parseInput(o[1],o[2],o[3],o[4],o[5])
end