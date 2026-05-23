package main

import (
	"log"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/paldfi/chaincode/pal-dfi/contracts"
)

func main() {
	chaincode, err := contractapi.NewChaincode(
		new(contracts.IdentityContract),
		new(contracts.IssuerContract),
		new(contracts.CredentialContract),
		new(contracts.AuditContract),
	)
	if err != nil {
		log.Panicf("failed to create chaincode: %v", err)
	}

	if err := chaincode.Start(); err != nil {
		log.Panicf("failed to start chaincode: %v", err)
	}
}
