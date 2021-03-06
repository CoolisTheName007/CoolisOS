------------------------------------------------------------------------------
-- Log library provides logging facilities.
-- The module exposes extension points. It is possible to provide both the custom printing function and the custom log saving function. <br />
-- The module is callable. Thus:
--    local log = require"log"
--    log("MODULE", "INFO", "message")
-- calls the @{#log.trace} function.
-- @module log
--
local string,pcall,table,tostring,setmetatable,os,pairs,next,print,math,type,unpack=
string,pcall,table,tostring,setmetatable,os,pairs,next,print,math,type,unpack
local base = _G

local util=require'kernel.util'
local check =require'kernel.checker'.check
local textutils=textutils
local string=string
--temporary
local pprint=pprint

--no more global access
local env=getfenv()
setmetatable(env,nil)

function s_to_real(t)
	local n_s=t%60
	local m=((t-n_s)/60)
	local n_m=m%60
	local h=((m-n_m)/60)
	return h,n_m,n_s
end
local os_time= function()
	local mc='Day '..os.day()..', '..textutils.formatTime(os.time())
	local t=os.clock()
	local h,n_m,n_s=s_to_real(t)
	local sec=tostring(n_s)
	local s,p,e=sec:match('^([^%.]*)(%.)([^%.]*)$')
	s=s or '0'
	p=p or '.'
	e=e or '0'
	s=string.rep('0',2-s:len())..s
	e=e..string.rep('0',2-e:len())
	sec=s..p..e
	local real=string.format('%sh%sm%ss',h,n_m,sec)
	return string.format('%s',sec)--string.format('%s;%s;%s',mc,real,sec)
end

-------------------------------------------------------------------------------
-- Log levels are strings used to filter logs.
-- Levels are to be used both in log filtering configuration (see @{#log.setLevel}) and each time 
-- @{#log.trace} function is used to issue a new log.
--
-- Levels are ordered by verbosity/severity level.
-- 
-- While configuring log filtering, if you set a module log level to 'INFO' level for exemple, you
-- enable all logs *up to* 'INFO', that is to say that logs with 'WARNING' and 'ERROR' severities will
-- be displayed too.
--
-- Built-in values (in order from the least verbose to the most): 
--    - 'NONE':    filtering only: when no log is wanted
--    - 'ERROR':   filtering or tracing level
--    - 'WARNING': filtering or tracing level
--    - 'INFO':    filtering or tracing level
--    - 'DETAIL':  filtering or tracing level
--    - 'DEBUG':   filtering or tracing level
--    - 'ALL':     filtering only: when all logs are to be displayed
-- @type levels 
--
levels = {}
-- Severity name <-> Severity numeric value translation table (internal purpose only)
for k,v in pairs{ 'NONE', 'ERROR', 'WARNING', 'INFO', 'DETAIL', 'DEBUG', 'ALL' } do
    levels[k], levels[v] = v, k
end

-- -----------------------------------------------------------------------------
-- Default verbosity level.  
-- Default value is `"WARNING"`.
-- @field [parent=#log] #levels defaultlevel
-- See @{#log} for a list of existing levels.

local defaultlevel = defaultlevel or levels.WARNING

-- -----------------------------------------------------------------------------
-- Per module verbosity levels.
-- @field [parent=#log] modules
-- See @{#levels} to see existing levels.

local modules = modules or { }


-- -----------------------------------------------------------------------------
-- The string format of the timestamp is the same as what os.date takes.
-- Example: "%F %T"
-- #field [parent=#log] #string timestampformat
timestampformat = nil

-- -----------------------------------------------------------------------------
-- logger functions, will be called if non nil
-- the loggers are called with following params (module, severity, logvalue)
-- -----------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Default logger for instant display.
-- This logger can be replaced by a custom function.   
-- It is called only if the log needs to be traced.
--
-- @function [parent=#log] displaylogger
-- @param #string module string identifying the module that issues the log
-- @param severity string representing the log level, see @{log#levels}.
-- @param msg string containing the message to log.
--
displaylogger = function(_, _, ...)
   -- if base.print then base.print(...) end
end

-------------------------------------------------------------------------------
-- Logger function for log storage.   
-- This logger can be replaced by a custom function.   
-- There is no default store logger.   
-- It is called only if the log needs to be traced (see @{#log.musttrace}) and after the log has been displayed using {displaylogger}.
--
-- @function [parent=#log] storelogger
-- @param module string identifying the module thats issues the log
-- @param severity string representing the log level, see @{log#levels}.
-- @param msg string containing the message to log.
--

storelogger = nil

-------------------------------------------------------------------------------
-- Format is a string used to apply specific formating before the log is outputted.  
-- Within a format, the following tokens are available (in addition to standard text)
-- 
--- %l => the actual log (given in 3rd argument when calling log() function)
--- %t => the current date
--- %m => module name
--- %s => log level (severity), see @{log#levels}
--@field [parent=#log] #string format
format = nil

local function loggers(...)
    if displaylogger then displaylogger(...) end
    if storelogger then storelogger(...) end
end

-------------------------------------------------------------------------------
-- Determines whether a log must be traced depending on its severity and the
-- module issuing the log. This function is mostly useful to protect `log()`
-- calls which involve costly computations
--
-- @usage
--
--    if log.musttrace('SAMPLE', 'DEBUG') then
--        log('SAMPLE', 'DEBUG', "Here are some hard-to-compute info: %s",
--            computeAndReturnExpensiveDebugString())
--    end
--
-- @function [parent=#log] musttrace
-- @param modulename string identifying the module that issues the log.
-- @param severity string representing the log level, see @{log#levels}.
-- @return `nil' if the message of the given severity by the given module should
-- not be printed.
-- @return `true` if the message should be printed.
--
function musttrace(module, severity)
    -- get the log level for this module, or default log level
    local lev, sev = modules[module] or defaultlevel, levels[severity]
    return not sev or lev >= sev
end

local function debug_getinfo(...)
	return (base.debug and base.debug.getinfo or tostring)(...)
end
-------------------------------------------------------------------------------
-- Prints out a log entry according to the module and the severity of the log entry.
--
-- This function uses @{#log.format} and @{#log.timestampformat} to create the
-- final message string. It calls @{#log.displaylogger} and @{#log.storelogger}.
--
-- @function [parent=#log] trace 
-- @param modulename string identifying the module that issues the log.
-- @param severity string representing the level in @{log#levels}.
-- @param fmt string format that holds the log text the same way as string.format does.
-- @param varargs additional arguments can be provided (as with string.format).
-- @usage trace("MODULE", "INFO", "message=%s", "sometext").
--
function trace(module, severity, fmt, ...)
    check('string,string,string',module, severity, fmt)
    if not musttrace(module, severity) then return end
    local c, s = pcall(string.format,fmt, unpack(util.map_args({...},function(v) if (type(v)=='number' or type(v)=='string') then return v else return debug_getinfo(v) end end)))
    if c then
        local t
        local function sub(p)
            if     p=="l" then return s
            elseif p=="t" then t = t or tostring(os_time(timestampformat)) return t
            elseif p=="m" then return module
            elseif p=="s" then return severity
            else return p end
        end
        local out = (format or "%t %m-%s: %l"):gsub("%%(%a)", sub)
        loggers(module, severity, out)
    else -- fallback printing when the formating failed. The fallback printing allow to safely print what was given to the log function, without crashing the thread !
		
        --trace(module, severity, "\targs=("..table.concat(args, " ")..")" )
        loggers(module, severity, "Error in the log formating! ("..tostring(s)..") - Fallback to raw printing:" )
        loggers(module, severity, string.format("\tmodule=(%s), severity=(%s), format=(%q), args=(%s)", module, severity, fmt,table.concat(util.map_args({...},debug.getinfo),',') ))
    end
end


-------------------------------------------------------------------------------
-- Sets the log level for a list of module names.
-- If no module name is given, the default log level is affected
-- @function [parent=#log] setLevel
-- @param slevel level as in @{log#levels}
-- @param varargs Optional list of modules names (string) to apply the level to.
-- @return nothing.
--
function setLevel(slevel, ...)
    local mods = {...}
    local nlevel = levels[slevel] or levels['ALL']
    if not levels[slevel] then
        trace("LOG", "ERROR", "Unknown severity %q, reverting to 'ALL'", tostring(slevel))
    end
    if next(mods) then for _, m in pairs(mods) do modules[m] = nlevel end
    else defaultlevel = nlevel end
end

---
local wrapped=setmetatable({},{__mode='k'})
function wrap_class(k)
	assert(not wrapped[k])
	local old=k.__init
	rawset(k,'__init',function(...)
		old(...)
		env(tostring(k.__name),'DETAIL','initiated obj %s with args ',debug.getinfo(obj),args_tostring(...))
	end)
	wrapped[k]=old
end
function unwrapp_class(k)
	if wrapped[k] then
		rawset(k,'__init',wrapped[k])
		wrapped[k]=nil
	end
end
-- -----------------------------------------------------------------------------
-- Make the module callable, so the user can call log(x) instead of log.trace(x)
-- -----------------------------------------------------------------------------
setmetatable(env, {__call = function(_, ...) return trace(...) end })
return env

