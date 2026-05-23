@echo off
setlocal

title PAL-DFI Channel Recovery

echo ==========================================
echo PAL-DFI Channel Recovery
echo Rejoin all peers to palidentitychannel
echo ==========================================
echo.

set ROOT=C:\Users\HP\Desktop\SandadProject\pal-dfi
set BLOCK=%ROOT%\network\channel-artifacts\palidentitychannel.block

if not exist "%BLOCK%" (
    echo ERROR: Channel block not found:
    echo %BLOCK%
    pause
    exit /b 1
)

echo Channel block found:
echo %BLOCK%
echo.

echo ==========================================
echo STEP 1 - Copy block to peers
echo ==========================================

docker cp "%BLOCK%" peer0.pma.ps:/tmp/palidentitychannel.block
if errorlevel 1 goto FAIL

docker cp "%BLOCK%" peer0.moi.ps:/tmp/palidentitychannel.block
if errorlevel 1 goto FAIL

docker cp "%BLOCK%" peer0.jawwal.ps:/tmp/palidentitychannel.block
if errorlevel 1 goto FAIL

echo Block copied successfully.
echo.

echo ==========================================
echo STEP 2 - Join PMA peer
echo ==========================================

docker exec peer0.pma.ps peer channel join -b /tmp/palidentitychannel.block
if errorlevel 1 goto FAIL

echo.

echo ==========================================
echo STEP 3 - Join MOI peer
echo ==========================================

docker exec peer0.moi.ps peer channel join -b /tmp/palidentitychannel.block
if errorlevel 1 goto FAIL

echo.

echo ==========================================
echo STEP 4 - Join JAWWAL peer
echo ==========================================

docker exec peer0.jawwal.ps peer channel join -b /tmp/palidentitychannel.block
if errorlevel 1 goto FAIL

echo.
echo ==========================================
echo STEP 5 - Verify channel membership
echo ==========================================

echo PMA:
docker exec peer0.pma.ps peer channel list

echo.
echo MOI:
docker exec peer0.moi.ps peer channel list

echo.
echo JAWWAL:
docker exec peer0.jawwal.ps peer channel list

echo.
echo ==========================================
echo SUCCESS
echo All peers joined palidentitychannel
echo ==========================================
pause
exit /b 0

:FAIL
echo.
echo ==========================================
echo FAILED
echo Check Docker containers / channel block
echo ==========================================
pause
exit /b 1