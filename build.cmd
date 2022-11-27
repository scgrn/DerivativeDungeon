@echo off

:: remove previous build artifacts
rd /S /Q bin 2> nul
rd /S /Q build 2> nul

md build
cd build
cmake ..
cd..
cmake --build build

