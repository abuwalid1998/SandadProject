#!/bin/bash
set -e

CHANNEL_NAME=palidentitychannel
CC_NAME=paldfi
CC_VERSION=1.0
CC_SEQUENCE=1
CC_SRC_PATH=../chaincode/pal-dfi
CC_RUNTIME_LANGUAGE=golang
PACKAGE_FILE=${CC_NAME}.tar.gz

echo "Packaging chaincode..."
peer lifecycle chaincode package $PACKAGE_FILE \
  --path $CC_SRC_PATH \
  --lang $CC_RUNTIME_LANGUAGE \
  --label ${CC_NAME}_${CC_VERSION}

echo "Installing on PMA..."
peer lifecycle chaincode install $PACKAGE_FILE

echo "Query installed..."
peer lifecycle chaincode queryinstalled

echo "Set PACKAGE_ID manually from output."
echo "Example:"
echo "paldfi_1.0:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

read -p "Enter PACKAGE_ID: " PACKAGE_ID

echo "Approve PMA..."
peer lifecycle chaincode approveformyorg \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --tls \
  --cafile $ORDERER_CA \
  --channelID $CHANNEL_NAME \
  --name $CC_NAME \
  --version $CC_VERSION \
  --package-id $PACKAGE_ID \
  --sequence $CC_SEQUENCE

echo "Repeat approval for MOI and JAWWAL environments."

echo "Commit..."
peer lifecycle chaincode commit \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --tls \
  --cafile $ORDERER_CA \
  --channelID $CHANNEL_NAME \
  --name $CC_NAME \
  --peerAddresses localhost:7051 \
  --tlsRootCertFiles $PMA_PEER_TLSCERT \
  --peerAddresses localhost:9051 \
  --tlsRootCertFiles $MOI_PEER_TLSCERT \
  --peerAddresses localhost:11051 \
  --tlsRootCertFiles $JAWWAL_PEER_TLSCERT \
  --version $CC_VERSION \
  --sequence $CC_SEQUENCE

echo "Committed successfully."