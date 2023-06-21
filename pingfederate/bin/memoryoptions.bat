@echo off
setlocal enabledelayedexpansion

if not "%OS%" == "Windows_NT" (
    echo Unsupported operating system
    EXIT /B 1
)

if "%PF_HOME%" == "" (
    set "pfBin=%~dp0"
    set "PF_HOME=!pfBin!.."
)

REM get the current time
for /f %%a in ('wmic os get LocalDateTime ^| findstr ^[0-9]') do (
   if !errorlevel! NEQ 0 GOTO :ERROR
   set ts=%%a
)
set Y=%ts:~0,4%
set M=%ts:~4,2%
set D=%ts:~6,2%
set H=%ts:~8,2%
set MN=%ts:~10,2%
set S=%ts:~12,2%
set MIL=%ts:~15,3%
set backupDateTime=%Y%-%M%-%D%_%H%-%MN%-%S%-%MIL%
set "generatedTime=%Y%/%M%/%D% %H%:%MN%:%S%:%MIL%"


REM ********* File Template *********
REM Each line must end with a "^" and be separated by a space
set file=^
# Auto-generated JVM memory options for PingFederate^

#^

# Generated: !generatedTime!^

#^

# Each non-commented and non-empty line will be added as a Java option when PingFederate is started.^

# Comments can be added to this file by starting a line with the # character.^

#^

^

#Initial RAM percentage^

-XX:InitialRAMPercentage=80.0^

#Maximum RAM percentage^

-XX:MaxRAMPercentage=80.0^

#Use G1GC^

-XX:+UseG1GC
REM ******* End File Template *******

set "jvmMemoryOpts=%PF_HOME%\bin\jvm-memory.options"
if exist "%jvmMemoryOpts%" (
    REM Make a backup before generating a new file
    copy "%jvmMemoryOpts%" "%PF_HOME%\bin\jvm-memory_%backupDateTime%.options" || GOTO :ERROR
)

echo !file! > "%jvmMemoryOpts%" || GOTO :ERROR
echo.
echo Generated new jvm-memory.options.
EXIT /B 

:ERROR
echo Unable to generate jvm-memory.options. An error occurred.
EXIT /B 1