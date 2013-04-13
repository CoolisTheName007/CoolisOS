luau_={}
luau_.n=0
luau_.opt={}
luau_.mac={}
luau_.mac.la={['def']='os.loadAPI("%1")',['pnum']=1}
luau_.opt.skip_lines={
['type']='number',
['value']=0,
['default']=0,
['desc']='Number of blank lines to skip between input/output pairs.'
}
luau_.opt.use_color={
['type']='boolean',
['value']=true,
['default']=true,
['desc']='Whether to use color, if available.'
}
in_={}
out_={}
luau_.help={}
luau_.help.summary='The following topics are available, and can be abbreviated--for instance, "/help sub" for "/help substitution".'
luau_.help.substitution='Typing "s/find-expr/replace-expr/" will repeat the previously entered line, but with all occurrences of find-expr replaced by replace-expr. Lua\'s string-matching patterns may be used in find-expr. This is often quicker than using up-arrow to recall the command and editing it manually.'
luau_.help.history='The tables in_ and out_ hold the input and output histories, and can be referenced, for example: "result=out_[9]".'
luau_.help['repeat-command']='To repeat a previous input, use the "!<n>" command. For example, typing !23 will re-evaluate the 23rd command in the history.'
luau_.help['question-mark']='The "?" character is a shortcut for print: "?foo" is short for "print(foo)". If foo is a table, then its keys and values will be displayed.'
luau_.help['macros']='You can define macros to shorten frequently-typed strings. For example, if you type "/macro %la=os.loadAPI", then in the future any occurence of "%la" in commands you type will be changed to "os.loadAPI" before processing by Lua.\n\nMacros can also accept parameters. For example, "/macro %rs=rednet.send(%1,%2)" will tell luau to expand "%rs[23][\'hi!\']" into "rednet.send(23,\'hi!\')".\n\nParameters may appear more than once and out of order--a silly example is "/macro %palindrome=%3%2%1%2%3", which expands "%palindrome[A][B][C]" into "CBABC".'
luau_.help['commands']='Luau has some built-in commands which are invoked by starting a line with the slash "/" character. Type "/commands" for a list.'
luau_.helpkeys={}
for e in pairs(luau_.help)do
if e~='summary'then
table.insert(luau_.helpkeys,e)
end
end
table.sort(luau_.helpkeys)
if term.isColor()then
term.setTextColor(colors.gray)
luau_.setColor=function(e)
if luau_.opt.use_color.value then
term.setTextColor(e)
else
term.setTextColor(gray)
end
end
else
luau_.setColor=function(e)return end
end
luau_.terminated=false
function luau_.terminate()
luau_.terminated=true
end
function luau_.separator()
return(string.rep('-',term.getSize()))
end
function luau_.loadData()
local e
if fs.exists('luau.conf')then
e=fs.open('luau.conf','r')
local t,a
t=textutils.unserialize(e.readLine())
a=textutils.unserialize(e.readLine())
e.close()
if type(t)=='table'and type(a)=='table'then
luau_.opt=t
luau_.mac=a
return true
else
luau_.showError('Unable to load configuration; /luau.conf is corrupt. Exiting. (Delete or rename /luau.conf to start fresh)')
return false
end
else
luau_.setColor(colors.blue)
print('Configuration file /luau.conf does not exist; creating with default values.')
luau_.saveData()
return true
end
end
function luau_.saveData()
h=fs.open('luau.conf','w')
h.writeLine(textutils.serialize(luau_.opt))
h.writeLine(textutils.serialize(luau_.mac))
h.close()
end
function luau_.firstMatch(t,e)
for a,e in ipairs(e)do
if string.find(e,t)==1 then
return e
end
end
return nil
end
function luau_.showError(e)
luau_.setColor(colors.red)
print(e)
luau_.setColor(colors.gray)
end
function luau_.trim(e)
return(e:gsub("^%s*(.-)%s*$","%1"))
end
function luau_.macro(e)
local a,o,t
a,o,t=e:find('!(%d+)')
t=tonumber(t)
if a==1 then
if in_[t]then
e=in_[t]
else
luau_.showError("History entry "..tostring(t).." not found.")
e=''
end
return e
end
a,o,find,replace,flags=e:find('s/(.+)/(.*)/(.*)')
if find and in_[luau_.n]then
e=in_[luau_.n-1]:gsub(find,replace)
return e
end
local s,i='>tboss>','<tboss<'
for t,a in pairs(luau_.mac)do
local o='%%'..t..string.rep('(%b[])',a.pnum)
local t=e..string.rep('[ ]',a.pnum)
local h,n=t:find(o)
if n and n<=e:len()then
if t:find(o)then
local n=a.def:gsub('(%%%d)',s..'%1'..i)
t=t:gsub(o,n)
t=t:gsub(s..'%[','')
t=t:gsub('%]'..i,'')
e=t:sub(1,t:len()-3*a.pnum)
end
end
end
return e
end
function luau_.columnList(a)
local e=0
for a,t in ipairs(a)do
if string.len(t)>e then e=string.len(t)end
end
local t=2
local o,i=term.getSize()
local n=math.floor((o+t)/(e+t))
for i,o in ipairs(a)do
if(i%n==0)or(i==#a)then
print(o)
else
write(o..string.rep(' ',e+t-string.len(o)))
end
end
end
function luau_.showHelp(e)
luau_.setColor(colors.blue)
e=tostring(e)
if e~=''then
local t=luau_.firstMatch(e,luau_.helpkeys)
if luau_.help[t]then
local a,e=term.getSize()
textutils.pagedPrint('('..t..') '..luau_.help[t],e-3)
else
print('No help found for "'..e..'". Type "help" for a list of topics.')
end
else
print(luau_.help.summary)
print(luau_.separator())
luau_.columnList(luau_.helpkeys)
end
end
function luau_.searchHistory(a)
local e=0
for o,t in ipairs(in_)do
if string.find(t,a)then
print(o..': '..t)
e=e+1
end
end
return e
end
function luau_.keySort(t,e)
if type(t)=='number'and type(e)=='number'then
return t<e
elseif type(t)=='number'then
return true
elseif type(e)=='number'then
return false
elseif type(t)=='string'and type(e)=='string'then
return t<e
elseif type(t)=='string'then
return true
elseif type(e)=='string'then
return false
else
return(type(t)<type(e))
end
end
function luau_.serial(e)
if string.find("nil boolean number string table",type(e))then
local a,t=pcall(function()textutils.serialize(e)end)
if a then t=tostring(e)end
return t
else
return tostring(e)
end
end
function luau_.setMacro(e,t)
luau_.setColor(colors.yellow)
if e==''then
print("The following macros are currently defined:")
print(luau_.separator())
for e in pairs(luau_.mac)do
print("%"..e.."="..luau_.mac[e].def)
end
else
local o,o,e,a=e:find('%%([%w_]+)=(.*)')
if e then
if luau_.mac[e]and not t then
print('Macro %'..e..' is already defined. Use /Macro to overwrite it.')
return false
end
local t=0
a:gsub('%%(%d+)',function(e)t=tonumber(e)end)
luau_.mac[e]={['def']=a,['pnum']=t}
luau_.saveData()
else
luau_.showError('Invalid macro definition (see /help macro).')
return false
end
end
return true
end
function luau_.setOpt(e)
luau_.setColor(colors.yellow)
if e==''then
print('The following options are available. Type "/option <option_name>=<value>" to change, or "/option <option_name>" to get a description.')
local e={}
for t in pairs(luau_.opt)do e[#e+1]=t end
table.sort(e,luau_.keySort)
print(luau_.separator())
for t,e in ipairs(e)do
print(e..'='..tostring(luau_.opt[e].value))
end
elseif e:find('=')then
local a,a,t,i=e:find("([%w_]+)%s*=%s*(.*)")
if luau_.opt[t]then
local o=luau_.opt[t].type
local a=false
if o=='boolean'then
local e=i:lower()
if e=='true'or e=='1'or e=='yes'or e=='y'then
luau_.opt[t].value=true
a=true
elseif e=='false'or e=='0'or e=='no'or e=='n'then
luau_.opt[t].value=false
a=true
end
elseif o=='number'then
local e=tonumber(i)
if e then
luau_.opt[t].value=e
a=true
end
elseif o=='string'then
luau_.opt[t].value=i
a=true
end
if a then
luau_.saveData()
else
print('Value for '..t..' must be of type '..o..'.')
end
else
print('Option "'..e..'" not found. Type "/option" for a list.')
end
else
if luau_.opt[e]then
print(luau_.opt[e].desc..' [type='..luau_.opt[e].type..', value='..tostring(luau_.opt[e].value)..', default='..tostring(luau_.opt[e].default)..']')
else
print('Option "'..e..'" not found. Type "/option" for a list.')
end
end
end
function luau_.showCommands(e)
luau_.setColor(colors.blue)
if e==''then
print('The following commands are available. Type "/command <command-name>" for details.')
print(luau_.separator())
luau_.columnList(luau_.cmdNames)
else
local t=luau_.firstMatch(e,luau_.cmdNames)
if t then
print('/'..t..': '..luau_.cmd[t].desc)
else
print('Command "'..e..'" not found. Type "/commands" for a list.')
end
end
end
luau_.cmd={}
luau_.cmd.help={
['handler']=luau_.showHelp,
['desc']='Online help. Type "/help <topic>", or "/help" for a list of topics.',
}
luau_.cmd.exit={
['handler']=luau_.terminate,
['desc']='Exits Luau and returns you to the shell or wherever else you launched it from.',
}
luau_.cmd.history={
['handler']=luau_.searchHistory,
['desc']='Typing "/history" will simply print the entire history buffer, while "/history <pattern>" will only show entries matching <pattern>.',
}
luau_.cmd.macro={
['handler']=function(e)luau_.setMacro(e,false)end,
['desc']='Define a text-expansion macro with "/macro %<name>=<output>", or type "/macro" for a list of existing macros. Type "/help macros" for more details.',
}
luau_.cmd.Macro={
['handler']=function(e)luau_.setMacro(e,true)end,
['desc']='Same as "/macro", but able to overwrite existing definitions.',
}
luau_.cmd.options={
['handler']=luau_.setOpt,
['desc']='Type "/options" for a list of all options, "/option <name>" for an option\'s description, or "/option <name>=<value>" to change it.',
}
luau_.cmd.commands={
['handler']=luau_.showCommands,
['desc']='Type "/commands" for a list of commands, or "/command <command-name>" to view a description of a particular one.',
}
luau_.cmdNames={}
for e in pairs(luau_.cmd)do table.insert(luau_.cmdNames,e)end
table.sort(luau_.cmdNames)
function luau_.go()
if not luau_.loadData()then return false end
luau_.setColor(colors.blue)
print()
print('LUAU--LUA Upgraded v0.1 by Tinyboss\nType "/exit" to exit, "/help" for help.')
while not luau_.terminated do
luau_.setColor(colors.gray)
for e=1,luau_.opt.skip_lines.value do print()end
luau_.n=luau_.n+1
local e=''
while luau_.trim(e)==''do
luau_.setColor(colors.lime)
write(' in_['..luau_.n..']: ')
luau_.setColor(colors.lightGray)
e=luau_.trim(read(false,in_,getfenv(1)))
end
in_[luau_.n]=e
luau_.handled=false
if in_[luau_.n]:sub(1,1)=="?"then
rest_=luau_.trim(in_[luau_.n]:sub(2))
if rest_==""then
luau_.setColor(colors.blue)
print('"?foo" is a synonym for "print(foo)". Use "/help" for help.')
luau_.handled=true
elseif type(getfenv(1)[rest_])=="table"then
local e={}
for t in pairs(getfenv(1)[rest_])do
e[#e+1]=t
end
table.sort(e,luau_.keySort)
local t={}
for a,e in ipairs(e)do
t[a]=luau_.serial(e)..'='
..luau_.serial(getfenv(1)[rest_][e])
end
print('{',table.concat(t,', '),'}')
luau_.handled=true
else
in_[luau_.n]='print('..in_[luau_.n]:sub(2)..')'
end
end
if not luau_.handled then
local t,o,e,a=in_[luau_.n]:find('/(%a+)%s*(.*)')
if t==1 then
e=luau_.firstMatch(e,luau_.cmdNames)
if e then
luau_.cmd[e].handler(a)
else
luau_.setColor(colors.yellow)
print('Invalid command. (Try "/help".)')
end
else
in_[luau_.n]=luau_.macro(in_[luau_.n])
luau_.setColor(colors.gray)
is_print_=string.sub(in_[luau_.n],1,6)=='print('
func_,err_=loadstring('out_[luau_.n]='..in_[luau_.n])
if err_ then
func_,err_=loadstring(in_[luau_.n])
if err_ then
luau_.showError('(loadstring)'..err_)
else
setfenv(func_,getfenv(1))
success_,err_=pcall(func_)
if not success_ then
luau_.showError(err_)
end
end
else
setfenv(func_,getfenv(1))
success_,err_=pcall(func_)
if success_ then
if out_[luau_.n]and not is_print_ then
luau_.setColor(colors.green)
write('out_['..luau_.n..']: ')
luau_.setColor(colors.gray)
print(out_[luau_.n])
end
else
luau_.showError(err_)
end
end
end
end
end
luau_.saveData()
end
luau_.go()