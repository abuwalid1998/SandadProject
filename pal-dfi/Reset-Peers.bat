@echo off
setlocal EnableDelayedExpansion

cd /d C:\Users\HP\Desktop\SandadProject\pal-dfi

echo ==========================================
echo PAL-DFI SAFE RESET
echo ==========================================
echo.

echo Stopping Fabric containers...

docker rm -f orderer.ps >nul 2>&1
docker rm -f peer0.pma.ps >nul 2>&1
docker rm -f peer0.moi.ps >nul 2>&1
docker rm -f peer0.jawwal.ps >nul 2>&1

docker rm -f ca.orderer.ps >nul 2>&1
docker rm -f ca.pma.ps >nul 2>&1
docker rm -f ca.moi.ps >nul 2>&1
docker rm -f ca.jawwal.ps >nul 2>&1

docker rm -f fabric-tools >nul 2>&1

echo Removing old Docker network...

docker network rm paldfi_fabric_net >nul 2>&1

echo Cleaning generated artifacts only...

if exist network\organizations (
    rmdir /s /q network\organizations
)

if exist network\channel-artifacts (
    rmdir /s /q network\channel-artifacts
)

if exist network\system-genesis-block (
    rmdir /s /q network\system-genesis-block
)

mkdir network\organizations
mkdir network\channel-artifacts
mkdir network\system-genesis-block

echo Creating Docker network...

docker network create paldfi_fabric_net

echo ==========================================
echo SAFE RESET COMPLETE
echo ==========================================

pause