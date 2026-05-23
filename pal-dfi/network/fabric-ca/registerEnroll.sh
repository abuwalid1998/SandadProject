#!/bin/bash
set -e

ROOT=/workspace/network
ORG_ROOT=${ROOT}/organizations

mkdir -p ${ORG_ROOT}

createNodeOUConfig() {
  ORG_PATH=$1
  CA_CERT=$2

  mkdir -p ${ORG_PATH}/msp

  cat > ${ORG_PATH}/msp/config.yaml <<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/${CA_CERT}
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/${CA_CERT}
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/${CA_CERT}
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/${CA_CERT}
    OrganizationalUnitIdentifier: orderer
EOF
}

createOrderer() {
  echo "=== ORDERER ==="

  export FABRIC_CA_CLIENT_HOME=${ORG_ROOT}/ordererOrganizations/orderer.ps

  fabric-ca-client enroll \
    -u https://admin:adminpw@ca.orderer.ps:7054 \
    --caname ca-orderer \
    --tls.certfiles ${ROOT}/fabric-ca/orderer/ca-cert.pem

  createNodeOUConfig \
    ${ORG_ROOT}/ordererOrganizations/orderer.ps \
    ca-orderer-ps-7054-ca-orderer.pem

  fabric-ca-client register \
    --caname ca-orderer \
    --id.name orderer \
    --id.secret ordererpw \
    --id.type orderer \
    --tls.certfiles ${ROOT}/fabric-ca/orderer/ca-cert.pem || true

  fabric-ca-client register \
    --caname ca-orderer \
    --id.name ordererAdmin \
    --id.secret ordererAdminpw \
    --id.type admin \
    --tls.certfiles ${ROOT}/fabric-ca/orderer/ca-cert.pem || true

  fabric-ca-client enroll \
    -u https://orderer:ordererpw@ca.orderer.ps:7054 \
    --caname ca-orderer \
    -M ${ORG_ROOT}/ordererOrganizations/orderer.ps/orderers/orderer.ps/msp \
    --tls.certfiles ${ROOT}/fabric-ca/orderer/ca-cert.pem

  cp ${ORG_ROOT}/ordererOrganizations/orderer.ps/msp/config.yaml \
     ${ORG_ROOT}/ordererOrganizations/orderer.ps/orderers/orderer.ps/msp/config.yaml

  fabric-ca-client enroll \
    -u https://orderer:ordererpw@ca.orderer.ps:7054 \
    --caname ca-orderer \
    -M ${ORG_ROOT}/ordererOrganizations/orderer.ps/orderers/orderer.ps/tls \
    --enrollment.profile tls \
    --csr.hosts orderer.ps \
    --csr.hosts localhost \
    --tls.certfiles ${ROOT}/fabric-ca/orderer/ca-cert.pem

  cp ${ORG_ROOT}/ordererOrganizations/orderer.ps/orderers/orderer.ps/tls/keystore/* \
     ${ORG_ROOT}/ordererOrganizations/orderer.ps/orderers/orderer.ps/tls/keystore/priv_sk
}

createPeer() {
  ORG=$1
  PORT=$2
  CANAME=$3
  PEERHOST=$4
  ADMIN=$5
  ADMINPW=$6

  echo "=== ${ORG^^} ==="

  export FABRIC_CA_CLIENT_HOME=${ORG_ROOT}/peerOrganizations/${ORG}.ps

  fabric-ca-client enroll \
    -u https://admin:adminpw@ca.${ORG}.ps:${PORT} \
    --caname ${CANAME} \
    --tls.certfiles ${ROOT}/fabric-ca/${ORG}/ca-cert.pem

  createNodeOUConfig \
    ${ORG_ROOT}/peerOrganizations/${ORG}.ps \
    ${CANAME}-ps-${PORT}-${CANAME}.pem

  fabric-ca-client register \
    --caname ${CANAME} \
    --id.name peer0 \
    --id.secret peer0pw \
    --id.type peer \
    --tls.certfiles ${ROOT}/fabric-ca/${ORG}/ca-cert.pem || true

  fabric-ca-client register \
    --caname ${CANAME} \
    --id.name ${ADMIN} \
    --id.secret ${ADMINPW} \
    --id.type admin \
    --tls.certfiles ${ROOT}/fabric-ca/${ORG}/ca-cert.pem || true

  fabric-ca-client enroll \
    -u https://peer0:peer0pw@ca.${ORG}.ps:${PORT} \
    --caname ${CANAME} \
    -M ${ORG_ROOT}/peerOrganizations/${ORG}.ps/peers/${PEERHOST}/msp \
    --tls.certfiles ${ROOT}/fabric-ca/${ORG}/ca-cert.pem

  cp ${ORG_ROOT}/peerOrganizations/${ORG}.ps/msp/config.yaml \
     ${ORG_ROOT}/peerOrganizations/${ORG}.ps/peers/${PEERHOST}/msp/config.yaml

  fabric-ca-client enroll \
    -u https://peer0:peer0pw@ca.${ORG}.ps:${PORT} \
    --caname ${CANAME} \
    -M ${ORG_ROOT}/peerOrganizations/${ORG}.ps/peers/${PEERHOST}/tls \
    --enrollment.profile tls \
    --csr.hosts ${PEERHOST} \
    --csr.hosts localhost \
    --tls.certfiles ${ROOT}/fabric-ca/${ORG}/ca-cert.pem

  cp ${ORG_ROOT}/peerOrganizations/${ORG}.ps/peers/${PEERHOST}/tls/keystore/* \
     ${ORG_ROOT}/peerOrganizations/${ORG}.ps/peers/${PEERHOST}/tls/keystore/priv_sk

  fabric-ca-client enroll \
    -u https://${ADMIN}:${ADMINPW}@ca.${ORG}.ps:${PORT} \
    --caname ${CANAME} \
    -M ${ORG_ROOT}/peerOrganizations/${ORG}.ps/users/Admin@${ORG}.ps/msp \
    --tls.certfiles ${ROOT}/fabric-ca/${ORG}/ca-cert.pem

  cp ${ORG_ROOT}/peerOrganizations/${ORG}.ps/msp/config.yaml \
     ${ORG_ROOT}/peerOrganizations/${ORG}.ps/users/Admin@${ORG}.ps/msp/config.yaml
}

echo "Creating identities..."

createOrderer
createPeer pma 9054 ca-pma peer0.pma.ps pmaAdmin pmaAdminpw
createPeer moi 8054 ca-moi peer0.moi.ps moiAdmin moiAdminpw
createPeer jawwal 10054 ca-jawwal peer0.jawwal.ps jawwalAdmin jawwalAdminpw

echo "Enrollment complete."