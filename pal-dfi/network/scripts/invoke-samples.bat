@echo off
setlocal

REM ==============================
REM PAL-DFI Invoke Test Script
REM ==============================

set CHANNEL_NAME=palidentitychannel
set CC_NAME=paldfi

REM UPDATE THESE PATHS FOR YOUR NETWORK
set ORDERER_CA=%CD%\..\organizations\ordererOrganizations\example.com\orderers\orderer.example.com\msp\tlscacerts\tlsca.example.com-cert.pem
set PMA_TLS=%CD%\..\organizations\peerOrganizations\pma.example.com\peers\peer0.pma.example.com\tls\ca.crt

echo =====================================
echo Register PMA issuer
echo =====================================

peer chaincode invoke ^
-o localhost:7050 ^
--ordererTLSHostnameOverride orderer.example.com ^
--tls ^
--cafile "%ORDERER_CA%" ^
-C %CHANNEL_NAME% ^
-n %CC_NAME% ^
--peerAddresses localhost:7051 ^
--tlsRootCertFiles "%PMA_TLS%" ^
-c "{\"Args\":[\"RegisterIssuer\",\"PMA\",\"Palestine Monetary Authority\",\"PMAMSP\",\"REGULATOR\"]}"

pause

echo =====================================
echo Register Citizen
echo =====================================

peer chaincode invoke ^
-o localhost:7050 ^
--ordererTLSHostnameOverride orderer.example.com ^
--tls ^
--cafile "%ORDERER_CA%" ^
-C %CHANNEL_NAME% ^
-n %CC_NAME% ^
--peerAddresses localhost:7051 ^
--tlsRootCertFiles "%PMA_TLS%" ^
-c "{\"Args\":[\"RegisterCitizen\",\"CID001\",\"403391790\",\"Amjad Khaliliah\",\"1990-01-01\",\"0599999999\",\"amjad@test.com\",\"Ramallah\"]}"

pause

echo =====================================
echo Query Citizen
echo =====================================

peer chaincode query ^
-C %CHANNEL_NAME% ^
-n %CC_NAME% ^
-c "{\"Args\":[\"GetCitizen\",\"CID001\"]}"

pause