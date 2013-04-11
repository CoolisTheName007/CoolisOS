---patches
do

local function wrap(text, limit) --from Kingdaroo
        local lines = {''}
        for word, space in text:gmatch('(%S+)(%s*)') do
                local temp = lines[#lines] .. word .. space:gsub('\n','')
                if #temp > limit then
                        table.insert(lines, '')
                end
                if space:find('\n') then
                        lines[#lines] = lines[#lines] .. word
                        
                        space = space:gsub('\n', function()
                                table.insert(lines, '')
                                return ''
                        end)
                else
                        lines[#lines] = lines[#lines] .. word .. space
                end
        end
        return lines
end

-- function get_lines(s,x)
	-- local t={}
	-- for line in s:gmatch("([^\n]*)\n?") do
		-- table.insert(t,line)
	-- end
	-- local tt={}
	-- for _,line in pairs(t) do
		-- local n=line:sub(-1,-1)=='\n' and #line-1 or #line
		-- local r=n%x
		-- local q=(n-r)/x
		-- for j=1,q do
			-- table.insert(qq,
		-- end
		-- if r~=0 then 	end
	-- end
	-- return t
-- end

function step_print(s,_term)
	local term=_term or term
	local x,y=term.getSize()
	local t=wrap(s,x)
	local r=#t%y
	local n=(#t-r)/y
	for i=0,n-1 do
		write(table.concat(t,'\n',i*y+1,(i+1)*y))
		os.pullEvent('key')
	end
	write(table.concat(t,'\n',n*y+1,n*y+r))
	os.pullEvent('key')
	write('\n')
end

rawset(_G,'printError',function( ... )
	if term.isColour() then
		term.setTextColour( colours.red )
	end
	local t={...}
	for i=1,#t do t[i]=tostring(t[i]) end
	step_print(table.concat(t,''),term)
	term.setTextColour( colours.white )
end)

end


do
--[[ Notes:
getfenv(1)=getfenv()~=getfenv(0)~~_G
error('',1)~=error('',0)
]]
rawset(_G,'loadfile',function( _sFile )
  local file = fs.open( _sFile, "r" )
  if file then
    local func, err = loadstring( file.readAll(),_sFile)
    file.close()
    return func, err
  end
  return nil, "File not found"
end)
local old_error=_G._error or error
local new_error

local traceback=function(level,terr)
  local terr=terr or {}
  local passed={}
  local err,ok=terr
  local j=1+(level or 0)
  repeat
    j=j+1
    passed[err]=true
    ok,err=pcall(old_error,'',j)
    if err:match('^[^:]+')=='bios' then break end
    table.insert(terr,err)
  until (passed[err])
 
  return terr
end

local function classify(t,f)
  local bins={}
  local c
  for i,v in ipairs(t) do
    local fi,r=f(v)
    if fi~=nil then
      if c==nil or c.n~=fi then
        table.insert(bins,c)
        c={n=fi}
      end
      table.insert(c,r)
    end
  end
  table.insert(bins,c)
  return bins
end
local function get_chunks(terr)
  return classify(terr,function(v) return v:match('^([^:]+):(.*)') end)
end

local function get_lines(terr)
  return classify(terr,function(v) return v:match('^(%d+):(.*)') end)
end

local function put_lines(path,diameter,ts,l)
  local ok,f=pcall(fs.open,path,'r')
  if not ok or not f then table.insert(ts,'  (could not open file)')
  else
    for i=1,l-diameter-1 do
      f.readLine()
    end
    for i=1,diameter do
      table.insert(ts,'  '..f.readLine())
    end
    table.insert(ts,'->'..f.readLine())
    for i=1,diameter do
      local l=f.readLine()
      if l then table.insert(ts,'  '..l)
      else break end
    end
  end
end

local function format_traceback(terr)
  local ts={}
  for i,v in ipairs(get_chunks(terr)) do
    local name=v.n or '(no name)'
    local path
    if fs.exists(name) then
      name,dir,path=fs.getName(name),name:match('^(.*)/') or '/',name
      name=name..' ('..(dir or 'unknown')..')'
    elseif false then
      --shell has input string; modify to behave as file?
    end
    table.insert(ts,name)
    for j,line in ipairs(get_lines(v)) do
      table.insert(ts,' line '..(line.n or '(no line)')..', *'..(#line))
      local n=line.n and tonumber(line.n) or 1
      if path and n then
        put_lines(path,1,ts,n)
      end
    end
  end
  return ts
end

new_error=function(msg,level)
  if level and type(level)~='number' then new_error('expected arg2 to be nil or number,got '..type(level),1) end
  if msg and type(msg)~='string' then new_error('expected arg1 to be nil or string,got '..type(msg),1) end
  
  level=level or 0
  local ts=format_traceback(traceback(level+2,{}))
  msg='\1'..(msg or '')
  table.insert(ts,1,msg)
  old_error(table.concat(ts,'\n'),level+2)
end
rawset(_G,'_error',old_error)
rawset(_G,'error',new_error)
rawset(_G,'toerror',function(s)
	if not s:match'^[^:]+:%d+:\1' then
		local ts=format_traceback{s}
		table.insert(ts,1,s)
		return table.concat(ts,'\n')
	end
	return s
end)
  
end