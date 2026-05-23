# PAL-DFI Hyperledger Fabric Network Establishment Guide

## Objective

This document provides the complete step-by-step operational procedure used to establish the PAL-DFI Hyperledger Fabric consortium blockchain network.

Consortium members:

- PMA (Palestinian Monetary Authority)
- MOI (Ministry of Interior)
- JAWWAL (Telecom Identity Provider)

Fabric components:

- Orderer
- 3 Peers
- 4 Certificate Authorities
- Fabric tools container
- Consortium channel: `palidentitychannel`

---

# Architecture Overview

```text
                    +----------------------+
                    |    CA ORDERER        |
                    +----------------------+

+----------------------+   +----------------------+   +----------------------+
|      CA PMA          |   |      CA MOI          |   |    CA JAWWAL         |
+----------------------+   +----------------------+   +----------------------+

+----------------------+      +----------------------+
|     peer0.pma.ps     |------|                      |
+----------------------+      |                      |
                              |   palidentitychannel |
+----------------------+      |                      |
|     peer0.moi.ps     |------|                      |
+----------------------+      |                      |
                              +----------------------+
+----------------------+               |
|   peer0.jawwal.ps    |---------------|
+----------------------+               |
                                       |
                              +----------------------+
                              |      orderer.ps      |
                              +----------------------+
```

---

# Prerequisites

Required software:

- Docker Desktop
- Docker Compose
- PowerShell
- Hyperledger Fabric Docker images

Project path:

```powershell
C:\Users\HP\Desktop\SandadProject\pal-dfi
```

---

# Step 1 — Cleanup Existing Environment

List containers:

```powershell
docker ps -a --format "{{.Names}}"
```

Remove old Fabric containers:

```powershell
docker rm -f orderer.ps peer0.pma.ps peer0.moi.ps peer0.jawwal.ps fabric-tools ca.orderer.ps ca.pma.ps ca.moi.ps ca.jawwal.ps
```

If Docker network exists:

```powershell
docker network inspect paldfi_fabric_net
```

If network removal fails:

```powershell
docker network rm paldfi_fabric_net
```

If active endpoints error appears:

```text
network has active endpoints
```

Inspect endpoints:

```powershell
docker network inspect paldfi_fabric_net
```

Remove attached containers.

Recreate network:

```powershell
docker network create paldfi_fabric_net
```

---

# Step 2 — Start Certificate Authorities

Move to project:

```powershell
cd C:\Users\HP\Desktop\SandadProject\pal-dfi
```

Start CA containers:

```powershell
docker compose -f network\docker-compose-ca.yaml up -d
```

Verify:

```powershell
docker ps --format "table {{.Names}}\t{{.Status}}"
```

Expected:

```text
ca.orderer.ps
ca.pma.ps
ca.moi.ps
ca.jawwal.ps
```

---

# Step 3 — Fix Windows CRLF Issue

Problem:

```text
registerEnroll.sh: line 3: $'\r': command not found
```

Fix:

```powershell
powershell -Command "$c=Get-Content 'network\fabric-ca\registerEnroll.sh' -Raw; $c=$c -replace \"`r\",\"\"; [System.IO.File]::WriteAllText('network\fabric-ca\registerEnroll.sh',$c,(New-Object System.Text.UTF8Encoding($false)))"
```

---

# Step 4 — Enrollment

Run network creation script:

```powershell
.\Create-Network.bat
```

Expected:

```text
Enrollment complete
```

Generated directories:

```text
network/organizations
network/fabric-ca
```

---

# Step 5 — Open Fabric Tools

```powershell
docker exec -it fabric-tools bash
```

Go to network:

```bash
cd /workspace/network
```

---

# Step 6 — Generate Genesis Block

Generate system genesis:

```bash
configtxgen \
-profile PalDFIOrdererGenesis \
-channelID system-channel \
-outputBlock ./system-genesis-block/genesis.block \
-configPath ./configtx
```

Expected:

```text
Writing genesis block
```

---

# Step 7 — Start Fabric Runtime

PowerShell:

```powershell
docker compose -f network\docker-compose-fabric.yaml up -d
```

Verify:

```powershell
docker ps --format "table {{.Names}}\t{{.Status}}"
```

Expected:

```text
orderer.ps
peer0.pma.ps
peer0.moi.ps
peer0.jawwal.ps
fabric-tools
```

---

# Step 8 — Generate Channel Artifacts

Inside fabric-tools:

```bash
cd /workspace/network
```

Create channel TX:

```bash
configtxgen \
-profile PalDFIChannel \
-channelID palidentitychannel \
-outputCreateChannelTx ./channel-artifacts/palidentitychannel.tx \
-configPath ./configtx
```

Create PMA anchor:

```bash
configtxgen \
-profile PalDFIChannel \
-channelID palidentitychannel \
-outputAnchorPeersUpdate ./channel-artifacts/PMAanchors.tx \
-asOrg PMAMSP \
-configPath ./configtx
```

Create MOI anchor:

```bash
configtxgen \
-profile PalDFIChannel \
-channelID palidentitychannel \
-outputAnchorPeersUpdate ./channel-artifacts/MOIanchors.tx \
-asOrg MOIMSP \
-configPath ./configtx
```

Create JAWWAL anchor:

```bash
configtxgen \
-profile PalDFIChannel \
-channelID palidentitychannel \
-outputAnchorPeersUpdate ./channel-artifacts/JAWWALanchors.tx \
-asOrg JAWWALMSP \
-configPath ./configtx
```

Verify:

```bash
ls -l ./channel-artifacts
```

Expected:

```text
palidentitychannel.tx
PMAanchors.tx
MOIanchors.tx
JAWWALanchors.tx
```

---

# Step 9 — Create Channel

Set PMA context:

```bash
export FABRIC_CFG_PATH=/etc/hyperledger/fabric
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID=PMAMSP
export CORE_PEER_MSPCONFIGPATH=/workspace/network/organizations/peerOrganizations/pma.ps/users/Admin@pma.ps/msp
export CORE_PEER_TLS_ROOTCERT_FILE=/workspace/network/organizations/peerOrganizations/pma.ps/peers/peer0.pma.ps/tls/tlscacerts/tls-ca-pma-ps-9054-ca-pma.pem
export CORE_PEER_ADDRESS=peer0.pma.ps:7051
```

Create channel:

```bash
peer channel create \
-o orderer.ps:7050 \
--ordererTLSHostnameOverride orderer.ps \
-c palidentitychannel \
-f ./channel-artifacts/palidentitychannel.tx \
--outputBlock ./channel-artifacts/palidentitychannel.block \
--tls \
--cafile /workspace/network/organizations/ordererOrganizations/orderer.ps/orderers/orderer.ps/tls/tlscacerts/tls-ca-orderer-ps-7054-ca-orderer.pem
```

Expected:

```text
Received block: 0
```

---

# Step 10 — Join PMA

```bash
export CORE_PEER_LOCALMSPID=PMAMSP
export CORE_PEER_MSPCONFIGPATH=/workspace/network/organizations/peerOrganizations/pma.ps/users/Admin@pma.ps/msp
export CORE_PEER_TLS_ROOTCERT_FILE=/workspace/network/organizations/peerOrganizations/pma.ps/peers/peer0.pma.ps/tls/tlscacerts/tls-ca-pma-ps-9054-ca-pma.pem
export CORE_PEER_ADDRESS=peer0.pma.ps:7051
```

Join:

```bash
peer channel join -b ./channel-artifacts/palidentitychannel.block
```

Expected:

```text
Successfully submitted proposal to join channel
```

---

# Step 11 — Join MOI

```bash
export CORE_PEER_LOCALMSPID=MOIMSP
export CORE_PEER_MSPCONFIGPATH=/workspace/network/organizations/peerOrganizations/moi.ps/users/Admin@moi.ps/msp
export CORE_PEER_TLS_ROOTCERT_FILE=/workspace/network/organizations/peerOrganizations/moi.ps/peers/peer0.moi.ps/tls/tlscacerts/tls-ca-moi-ps-8054-ca-moi.pem
export CORE_PEER_ADDRESS=peer0.moi.ps:7051
```

Join:

```bash
peer channel join -b ./channel-artifacts/palidentitychannel.block
```

---

# Step 12 — Join JAWWAL

```bash
export CORE_PEER_LOCALMSPID=JAWWALMSP
export CORE_PEER_MSPCONFIGPATH=/workspace/network/organizations/peerOrganizations/jawwal.ps/users/Admin@jawwal.ps/msp
export CORE_PEER_TLS_ROOTCERT_FILE=/workspace/network/organizations/peerOrganizations/jawwal.ps/peers/peer0.jawwal.ps/tls/tlscacerts/tls-ca-jawwal-ps-10054-ca-jawwal.pem
export CORE_PEER_ADDRESS=peer0.jawwal.ps:7051
```

Join:

```bash
peer channel join -b ./channel-artifacts/palidentitychannel.block
```

---

# Step 13 — Anchor Peer Updates

## PMA

```bash
peer channel update \
-o orderer.ps:7050 \
--ordererTLSHostnameOverride orderer.ps \
-c palidentitychannel \
-f ./channel-artifacts/PMAanchors.tx \
--tls \
--cafile /workspace/network/organizations/ordererOrganizations/orderer.ps/orderers/orderer.ps/tls/tlscacerts/tls-ca-orderer-ps-7054-ca-orderer.pem
```

## MOI

```bash
export CORE_PEER_LOCALMSPID=MOIMSP
export CORE_PEER_MSPCONFIGPATH=/workspace/network/organizations/peerOrganizations/moi.ps/users/Admin@moi.ps/msp
export CORE_PEER_TLS_ROOTCERT_FILE=/workspace/network/organizations/peerOrganizations/moi.ps/peers/peer0.moi.ps/tls/tlscacerts/tls-ca-moi-ps-8054-ca-moi.pem
export CORE_PEER_ADDRESS=peer0.moi.ps:7051
```

```bash
peer channel update \
-o orderer.ps:7050 \
--ordererTLSHostnameOverride orderer.ps \
-c palidentitychannel \
-f ./channel-artifacts/MOIanchors.tx \
--tls \
--cafile /workspace/network/organizations/ordererOrganizations/orderer.ps/orderers/orderer.ps/tls/tlscacerts/tls-ca-orderer-ps-7054-ca-orderer.pem
```

## JAWWAL

```bash
export CORE_PEER_LOCALMSPID=JAWWALMSP
export CORE_PEER_MSPCONFIGPATH=/workspace/network/organizations/peerOrganizations/jawwal.ps/users/Admin@jawwal.ps/msp
export CORE_PEER_TLS_ROOTCERT_FILE=/workspace/network/organizations/peerOrganizations/jawwal.ps/peers/peer0.jawwal.ps/tls/tlscacerts/tls-ca-jawwal-ps-10054-ca-jawwal.pem
export CORE_PEER_ADDRESS=peer0.jawwal.ps:7051
```

```bash
peer channel update \
-o orderer.ps:7050 \
--ordererTLSHostnameOverride orderer.ps \
-c palidentitychannel \
-f ./channel-artifacts/JAWWALanchors.tx \
--tls \
--cafile /workspace/network/organizations/ordererOrganizations/orderer.ps/orderers/orderer.ps/tls/tlscacerts/tls-ca-orderer-ps-7054-ca-orderer.pem
```

---

# Step 14 — Verification

Switch to PMA:

```bash
export CORE_PEER_LOCALMSPID=PMAMSP
export CORE_PEER_MSPCONFIGPATH=/workspace/network/organizations/peerOrganizations/pma.ps/users/Admin@pma.ps/msp
export CORE_PEER_TLS_ROOTCERT_FILE=/workspace/network/organizations/peerOrganizations/pma.ps/peers/peer0.pma.ps/tls/tlscacerts/tls-ca-pma-ps-9054-ca-pma.pem
export CORE_PEER_ADDRESS=peer0.pma.ps:7051
```

Verify:

```bash
peer channel getinfo -c palidentitychannel
```

Expected:

```text
Blockchain info: {"height":1}
```

---

# Troubleshooting

## CRLF issue

Error:

```text
registerEnroll.sh: $'\r'
```

Fix:

Use CRLF cleanup command.

---

## TLS unknown authority

Error:

```text
certificate signed by unknown authority
```

Fix:

Update peer Docker compose with orderer TLS trust.

---

## Missing channel artifact

Error:

```text
palidentitychannel.tx not found
```

Fix:

Regenerate artifacts.

---

## Invalid chain ID

Error:

```text
Invalid chain ID
```

Fix:

Peer not joined yet.

---

## Anchor update version conflict

Error:

```text
requires version 0 but currently version 1
```

Fix:

Anchor already applied.

---

# Final Status

Operational:

```text
orderer.ps
peer0.pma.ps
peer0.moi.ps
peer0.jawwal.ps
ca.orderer.ps
ca.pma.ps
ca.moi.ps
ca.jawwal.ps
fabric-tools
```

Channel:

```text
palidentitychannel
```

Status:

```text
WORKING
```