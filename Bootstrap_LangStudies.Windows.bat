git clone --recurse-submodules https://github.com/Ed94/LangStudies

cd LangStudies

start build_engine.debug.bat

start Engine\gd\bin\godot.windows.tools.64.exe -e Editor/project.godot
timeout 20
taskkill /f /im godot.windows.tools.64.exe


start /w build_engine.release.bat

start /w build_project.bat
