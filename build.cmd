@echo off

echo buildstamp = "%date:~10,4%-%date:~4,2%-%date:~7,2% %time:~0,-3%" >> script/buildstamp.lua

:: remove previous build artifacts
rd /S /Q bin 2> nul
rd /S /Q build 2> nul

md build
cd build
cmake ..
cd..
cmake --build build

