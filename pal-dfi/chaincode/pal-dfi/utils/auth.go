package utils

import (
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func GetClientMSPID(ctx contractapi.TransactionContextInterface) (string, error) {
	mspID, err := ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return "", fmt.Errorf("failed to get client MSP ID: %w", err)
	}
	return mspID, nil
}

func RequireMSP(ctx contractapi.TransactionContextInterface, allowedMSP string) error {
	clientMSP, err := GetClientMSPID(ctx)
	if err != nil {
		return err
	}

	if clientMSP != allowedMSP {
		return fmt.Errorf("access denied: client MSP [%s] not authorized", clientMSP)
	}

	return nil
}
