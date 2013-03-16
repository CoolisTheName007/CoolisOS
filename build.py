import os
import os.path as path
from subprocess import call

version='1.0'

lua_path="C:\\lua\\LuaRocks\\2.0\\lua5.1.exe"
print lua_path
diet_path=path.join('C:\\lua','LuaSrcDiet.lua')

project_path=path.dirname(path.realpath(__file__))
project_name=path.basename(project_path)
src_dir='src'
src_path=path.join(project_path,src_dir)
dist_path=path.join(project_path,'dist',("%s-%s"%(project_name,version)))
import shutil
try:
    shutil.rmtree(dist_path)
    os.rmdir(dist_path)
except:
    pass



for dirpath, dirnames, filenames in os.walk(src_path):
    r_path=dirpath.replace(src_path, dist_path)
    os.mkdir(r_path)
    for filename in filenames:
        src=path.join(dirpath,filename)
        dst=path.join(r_path,filename)
        if filename.endswith('.lua'):
            call([lua_path,diet_path,src,'-o',dst])
        else:
            shutil.copyfile(src, dst)