@echo off

set CORE_PEER_TLS_ENABLED=true
set CORE_PEER_LOCALMSPID=PMAMSP

set CORE_PEER_MSPCONFIGPATH=C:\PAL-DFI\network\organizations\peerOrganizations\pma.example.com\users\Admin@pma.example.com\msp

set CORE_PEER_ADDRESS=localhost:7051

set CORE_PEER_TLS_ROOTCERT_FILE=C:\PAL-DFI\network\organizations\peerOrganizations\pma.example.com\peers\peer0.pma.example.com\tls\ca.crt

set ORDERER_CA=C:\PAL-DFI\network\organizations\ordererOrganizations\example.com\orderers\orderer.example.com\msp\tlscacerts\tlsca.example.com-cert.pem

echo PMA environment loaded