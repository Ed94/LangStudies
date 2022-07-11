where "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" >nul 2>nul
if not ERRORLEVEL 0 (
	echo Visual Studio 2019 not found... Remove this error message if you do have it.
	pause
	exit
)

where scons >nul 2>nul
if not ERRORLEVEL 0 (
	python pip install scons
)

git clone --recurse-submodules https://github.com/Ed94/LangStudies

cd LangStudies

start build_engine.release.bat
timeout 10

start build_engine.release_debug.bat

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
