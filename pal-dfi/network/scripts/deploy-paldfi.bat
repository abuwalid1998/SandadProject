@echo off
set CHANNEL_NAME=palidentitychannel
set CC_NAME=paldfi
set CC_VERSION=1.0
set CC_SEQUENCE=1
set CC_SRC_PATH=..\chaincode\pal-dfi
set CC_RUNTIME_LANGUAGE=golang
set PACKAGE_FILE=%CC_NAME%.tar.gz

echo Packaging chaincode...
peer lifecycle chaincode package %PACKAGE_FILE% ^
 --path %CC_SRC_PATH% ^
 --lang %CC_RUNTIME_LANGUAGE% ^
 --label %CC_NAME%_%CC_VERSION%

echo Installing chaincode...
peer lifecycle chaincode install %PACKAGE_FILE%

echo Query installed...
peer lifecycle chaincode queryinstalled

echo Copy PACKAGE_ID from output
set /p PACKAGE_ID=Enter PACKAGE_ID:

echo Approving...
peer lifecycle chaincode approveformyorg ^
 -o localhost:7050 ^
 --ordererTLSHostnameOverride orderer.example.com ^
 --tls ^
 --cafile %ORDERER_CA% ^
 --channelID %CHANNEL_NAME% ^
 --name %CC_NAME% ^
 --version %CC_VERSION% ^
 --package-id %PACKAGE_ID% ^
 --sequence %CC_SEQUENCE%

echo Commit manually after all org approvals.
pause