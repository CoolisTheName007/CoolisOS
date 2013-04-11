--By CoolisTheName007
--CoolisOS/dev/help.lua

local mon=peripheral.wrap'back'
mon.setTextScale(1)
local delay=1
local textPath='CoolisOS/dev/text'

local function getText()
	local f=fs.open(textPath,'r')
	local text=f.readAll()
	f.close()
	return text
end

local function parse_text(text)
	for line in text:gmatch("([^\n]*)\n?") do
		local t,b=line:match'^#([^#- ]+)-?([^#- ]*)#'
	end
end

local function write( sText)
	local term=mon
	local w,h = term.getSize()		
	local x,y = term.getCursorPos()
	
	local nLinesPrinted = 0
	local function newLine()
		if y + 1 <= h then
			term.setCursorPos(1, y + 1)
		else
			term.setCursorPos(1, h)
			term.scroll(1)
		end
		x, y = term.getCursorPos()
		nLinesPrinted = nLinesPrinted + 1
	end
	
	-- Print the line with proper word wrapping
	while string.len(sText) > 0 do
		local whitespace = string.match( sText, "^[ \t]+" )
		if whitespace then
			-- Print whitespace
			term.write( whitespace )
			x,y = term.getCursorPos()
			sText = string.sub( sText, string.len(whitespace) + 1 )
		end
		
		local newline = string.match( sText, "^\n" )
		if newline then
			-- Print newlines
			newLine()
			sText = string.sub( sText, 2 )
		end
		
		local text = string.match( sText, "^[^ \t\n]+" )
		if text then
			sText = string.sub( sText, string.len(text) + 1 )
			if string.len(text) > w then
				-- Print a multiline word				
				while string.len( text ) > 0 do
					if x > w then
						newLine()
					end
					term.write( text )
					text = string.sub( text, (w-x) + 2 )
					x,y = term.getCursorPos()
				end
			else
				-- Print a word normally
				if x + string.len(text) - 1 > w then
					newLine()
				end
				term.write( text )
				x,y = term.getCursorPos()
			end
		end
	end
	
	return nLinesPrinted
end

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

local function extract(t,s,l)
	local c={}
	for k=s,s+l-1 do
		c[k-s+1]=t[k%(#t)+1]
	end
	return c
end

local function print_screen(t)
	mon.clear()
	mon.setCursorPos(1,1)
	local x,y=mon.getSize()
	
	
	for i,line in ipairs(t) do
		if (line:sub(1,1)=='#') then
			local tc=colors[line:match'^#([^-#]+)']
			mon.setTextColor(tc or colors.white)
			local bc=colors[line:match'^#[^-#]+%-([^#]+)#']
			mon.setBackgroundColor(bc or colors.black)
			local l=line:match'^#[^#]+#'
			line=line:sub(l:len()+1)
		end
		c=' '
		if (line:sub(-2,-2)=='&') then
			c=line:sub(-1,-1)
			line=line:sub(1,-3)
		end
		line=line..string.rep(c,math.max(x-#line,0))
		write(line..(i~=#t and '\n' or ''))
	end
end

local function main()
	local x,y=mon.getSize()
	local text
	local c=-1
	repeat
		
		local ok,r=pcall(getText)
		if ok then text=r else error(r) end
		local tText=wrap(text,x)
		c=(c+1)%(#tText)
		mon.setTextColor(colors.white)
		mon.setBackgroundColor(colors.black)
		local t=tText
		for i=1,(c+1) do
			local line=t[i]
			if (line:sub(1,1)=='#') then
				local tc=colors[line:match'^#([^-#]+)']
				mon.setTextColor(tc or colors.white)
				local bc=colors[line:match'^#[^-#]+%-([^#]+)#']
				mon.setBackgroundColor(bc or colors.black)
			end
		end
		print_screen(extract(tText,c,y))
		
		sleep(delay)
	until false
end
parallel.waitForAny(main,function() shell.run'shell' end)
