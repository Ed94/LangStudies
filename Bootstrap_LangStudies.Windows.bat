git clone --recurse-submodules https://github.com/Ed94/LangStudies

cd LangStudies

start build_engine.release_debug.bat
timeout 10

start build_engine.debug.bat

:tools_wait
timeout 1
if not exist Engine\gd\bin\godot.windows.tools.64.exe (
    goto :tools_wait
) 
timeout 10

start Engine\gd\bin\godot.windows.tools.64.exe -e Editor/project.godot
timeout 30

taskkill /f /im godot.windows.tools.64.exe

:opt_wait
timeout 1
if not exist Engine\gd\bin\godot.windows.opt.64.exe (
    goto :opt_wait
) 

start /w build_project.bat
