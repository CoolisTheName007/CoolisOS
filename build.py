import os
import os.path as path
from subprocess import call

version='1.0'


lua_path="C:\\lua\\LuaRocks\\2.0\\lua5.1.exe"
diet_path=path.join('C:\\lua','LuaSrcDiet.lua')
exclude={'impossibru'}
exclude_key='impossibru'

project_path=path.dirname(path.realpath(__file__))
project_name=path.basename(project_path)
src_dir='src'
src_path=path.join(project_path,src_dir)
dist_path=path.join(project_path,'dist')
dist_file_path=path.join(dist_path,"%s-%s"%(project_name,version))
build_path=path.join(project_path,'build')
import shutil
try:
    os.mkdir(dist_path)
except:
    pass
try:
    shutil.rmtree(build_path)
    os.rmdir(build_path)
except:
    pass

not_passed=dict()
for dirpath, dirnames, filenames in os.walk(src_path):
    r_path=dirpath.replace(src_path, build_path)
    os.mkdir(r_path)
    for filename in filenames:
        src=path.join(dirpath,filename)
        dst=path.join(r_path,filename)
        if filename.endswith('.lua') and not((dirpath in exclude) or (exclude_key in filename) or (filename in exclude)):
            result=call([lua_path,diet_path,src,'-o',dst])
            if not(os.access(dst, os.F_OK)):
                print(src)
                not_passed[src]=result
                shutil.copyfile(src, dst)
        else:
            shutil.copyfile(src, dst)
with open(dist_file_path,'w') as dist_file:
    dist_file.write('local t={')
    for dirpath, dirnames, filenames in os.walk(build_path):
        r_path=dirpath.replace(build_path,'CoolisOS')
        dist_file.write('"'+r_path.replace('\\','/')+'",true,')
        for filename in filenames:
            src=path.join(dirpath,filename)
            r_src=path.join(r_path,filename)
            
            with open(src) as file:
                all=file.read()
            dist_file.write('"'+r_src.replace('\\','/')+'",[===================[')
            dist_file.write(all)
            dist_file.write(']===================],')
    
    for i,v in not_passed.iteritems():
        print(i,':',v)
    try:
        shutil.rmtree(build_path)
        os.rmdir(build_path)
    except:
        pass
    dist_file.write('''
    }
    args={...}
    if args[1]=='help' or args[1]=='-help' or args[1]=='--help' then
    
    else
        local loc=shell.getRunningProgram()
        local llen=loc:len()
        local nlen=fs.getName(loc):len()
        loc=loc:sub(1,(llen==nlen and 0 or llen-nlen-1))
        print(args[1])
        print(loc)
        local r=args[1] or loc
        for i=1,#t,2 do
            p,v=t[i],t[i+1]
            p=fs.combine(r,p)
			if i~=1 then
				fs.delete(p)
			end
			if type(v)=='boolean' then
				fs.makeDir(p)
			else
				local f=fs.open(p,'w')
				f.write(v)
				f.close()
			end
        end
        local r_s=args[2] and r or ''
		if not fs.exists('startup') then
			fs.delete(fs.combine(r_s,'startup'))
			local f=fs.open(fs.combine(r_s,'startup'),'w')
			f.write(string.format("shell.run('%s')",s))
			f.close()
			print('Running startup')
			dofile(fs.combine(r_s,'startup'))
		end
    end
    
    ''')
    