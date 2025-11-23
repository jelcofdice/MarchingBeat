@echo off
set GODOT_PATH=godot

echo Running All Tests...
%GODOT_PATH% --headless TestRunner.tscn
if %ERRORLEVEL% NEQ 0 (
    echo Tests FAILED
    exit /b %ERRORLEVEL%
)

echo All tests passed!
