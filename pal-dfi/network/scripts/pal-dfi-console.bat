@echo off
setlocal EnableDelayedExpansion
title PAL-DFI Fabric Operations Console

echo ==========================================
echo Starting PAL-DFI Fabric Console
echo ==========================================
echo.

REM =========================================================
REM ROOT CONFIG
REM =========================================================
set ROOT=C:\Users\HP\Desktop\SandadProject\pal-dfi
set PATH=%ROOT%\bin;%PATH%
set FABRIC_CFG_PATH=%ROOT%\config

set CHANNEL_NAME=palidentitychannel
set CC_NAME=paldfi

REM =========================================================
REM AUTO-DETECT TLS CERTS
REM =========================================================
for %%f in ("%ROOT%\network\organizations\ordererOrganizations\orderer.ps\orderers\orderer.ps\tls\tlscacerts\*") do (
    set ORDERER_CA=%%f
)

for %%f in ("%ROOT%\network\organizations\peerOrganizations\pma.ps\peers\peer0.pma.ps\tls\tlscacerts\*") do (
    set PMA_TLS=%%f
)

for %%f in ("%ROOT%\network\organizations\peerOrganizations\moi.ps\peers\peer0.moi.ps\tls\tlscacerts\*") do (
    set MOI_TLS=%%f
)

for %%f in ("%ROOT%\network\organizations\peerOrganizations\jawwal.ps\peers\peer0.jawwal.ps\tls\tlscacerts\*") do (
    set JAWWAL_TLS=%%f
)

echo ORDERER_CA: !ORDERER_CA!
echo PMA_TLS   : !PMA_TLS!
echo MOI_TLS   : !MOI_TLS!
echo JAWWAL_TLS: !JAWWAL_TLS!
echo.

where peer
if errorlevel 1 (
    echo ERROR: peer CLI not found
    pause
    exit /b 1
)

if not exist "!ORDERER_CA!" (
    echo ERROR: Orderer TLS cert not found
    pause
    exit /b 1
)

goto MENU

REM =========================================================
REM ORG CONTEXT FUNCTIONS
REM =========================================================

:SET_PMA
set CORE_PEER_TLS_ENABLED=true
set CORE_PEER_LOCALMSPID=PMAMSP
set CORE_PEER_MSPCONFIGPATH=%ROOT%\network\organizations\peerOrganizations\pma.ps\users\Admin@pma.ps\msp
set CORE_PEER_ADDRESS=localhost:7051
set CORE_PEER_TLS_ROOTCERT_FILE=!PMA_TLS!
goto :eof

:SET_MOI
set CORE_PEER_TLS_ENABLED=true
set CORE_PEER_LOCALMSPID=MOIMSP
set CORE_PEER_MSPCONFIGPATH=%ROOT%\network\organizations\peerOrganizations\moi.ps\users\Admin@moi.ps\msp
set CORE_PEER_ADDRESS=localhost:9051
set CORE_PEER_TLS_ROOTCERT_FILE=!MOI_TLS!
goto :eof

:SET_JAWWAL
set CORE_PEER_TLS_ENABLED=true
set CORE_PEER_LOCALMSPID=JAWWALMSP
set CORE_PEER_MSPCONFIGPATH=%ROOT%\network\organizations\peerOrganizations\jawwal.ps\users\Admin@jawwal.ps\msp
set CORE_PEER_ADDRESS=localhost:11051
set CORE_PEER_TLS_ROOTCERT_FILE=!JAWWAL_TLS!
goto :eof

REM =========================================================
REM MENU
REM =========================================================

:MENU
cls
echo ==========================================
echo        PAL-DFI FABRIC OPERATIONS
echo ==========================================
echo.
echo 1. Query Committed Chaincode
echo 2. Register PMA Issuer
echo 3. Register MOI Issuer
echo 4. Register JAWWAL Issuer
echo 5. Register Citizen
echo 6. Query Citizen
echo 7. Exit
echo.
set /p CHOICE=Select option:

if "%CHOICE%"=="1" goto QUERY_CC
if "%CHOICE%"=="2" goto REG_PMA
if "%CHOICE%"=="3" goto REG_MOI
if "%CHOICE%"=="4" goto REG_JAWWAL
if "%CHOICE%"=="5" goto REG_CITIZEN
if "%CHOICE%"=="6" goto QUERY_CITIZEN
if "%CHOICE%"=="7" exit /b

goto MENU

REM =========================================================
REM OPERATIONS
REM =========================================================

:QUERY_CC
call :SET_PMA
echo Querying committed chaincode...
peer lifecycle chaincode querycommitted -C %CHANNEL_NAME%
pause
goto MENU

:REG_PMA
call :SET_PMA
echo Registering PMA issuer...

peer chaincode invoke ^
-o localhost:7050 ^
--ordererTLSHostnameOverride orderer.ps ^
--tls ^
--cafile "!ORDERER_CA!" ^
-C %CHANNEL_NAME% ^
-n %CC_NAME% ^
-c "{\"Args\":[\"RegisterIssuer\",\"PMA\",\"Palestine Monetary Authority\",\"PMAMSP\",\"REGULATOR\"]}"

pause
goto MENU

:REG_MOI
call :SET_PMA
echo Registering MOI issuer...

peer chaincode invoke ^
-o localhost:7050 ^
--ordererTLSHostnameOverride orderer.ps ^
--tls ^
--cafile "!ORDERER_CA!" ^
-C %CHANNEL_NAME% ^
-n %CC_NAME% ^
-c "{\"Args\":[\"RegisterIssuer\",\"MOI\",\"Ministry of Interior\",\"MOIMSP\",\"IDENTITY_AUTHORITY\"]}"

pause
goto MENU

:REG_JAWWAL
call :SET_PMA
echo Registering JAWWAL issuer...

peer chaincode invoke ^
-o localhost:7050 ^
--ordererTLSHostnameOverride orderer.ps ^
--tls ^
--cafile "!ORDERER_CA!" ^
-C %CHANNEL_NAME% ^
-n %CC_NAME% ^
-c "{\"Args\":[\"RegisterIssuer\",\"JAWWAL\",\"Jawwal Telecom\",\"JAWWALMSP\",\"TELCO\"]}"

pause
goto MENU

:REG_CITIZEN
call :SET_MOI

set /p CID=Citizen ID:
set /p NID=National ID:
set /p NAME=Full Name:
set /p DOB=Date of Birth (YYYY-MM-DD):
set /p MOBILE=Mobile:
set /p EMAIL=Email:
set /p ADDRESS=Address:

peer chaincode invoke ^
-o localhost:7050 ^
--ordererTLSHostnameOverride orderer.ps ^
--tls ^
--cafile "!ORDERER_CA!" ^
-C %CHANNEL_NAME% ^
-n %CC_NAME% ^
-c "{\"Args\":[\"RegisterCitizen\",\"!CID!\",\"!NID!\",\"!NAME!\",\"!DOB!\",\"!MOBILE!\",\"!EMAIL!\",\"!ADDRESS!\"]}"

pause
goto MENU

:QUERY_CITIZEN
call :SET_PMA

set /p CID=Citizen ID:

peer chaincode query ^
-C %CHANNEL_NAME% ^
-n %CC_NAME% ^
-c "{\"Args\":[\"GetCitizen\",\"!CID!\"]}"

pause
goto MENU