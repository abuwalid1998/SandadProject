package contracts

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/paldfi/chaincode/pal-dfi/models"
	"github.com/paldfi/chaincode/pal-dfi/repository"
	"github.com/paldfi/chaincode/pal-dfi/utils"
)

const RootGovernanceMSP = "PMAMSP"

var AllowedIssuerTypes = []string{
	"REGULATOR",
	"IDENTITY_AUTHORITY",
	"BANK",
	"TELCO",
	"FINTECH",
	"VERIFIER",
}

type IssuerContract struct {
	contractapi.Contract
}

func (c *IssuerContract) RegisterIssuer(
	ctx contractapi.TransactionContextInterface,
	issuerID string,
	organization string,
	mspID string,
	issuerType string,
) error {

	if err := utils.RequireMSP(ctx, RootGovernanceMSP); err != nil {
		return err
	}

	required := map[string]string{
		"issuerID":     issuerID,
		"organization": organization,
		"mspID":        mspID,
		"issuerType":   issuerType,
	}

	for k, v := range required {
		if err := utils.RequireNonEmpty(k, v); err != nil {
			return err
		}
	}

	if err := utils.RequireAllowedValue("issuerType", issuerType, AllowedIssuerTypes); err != nil {
		return err
	}

	repo := repository.NewLedgerRepository()
	key := utils.IssuerKey(issuerID)

	existing, err := repo.Get(ctx, key)
	if err != nil {
		return err
	}

	if existing != nil {
		return fmt.Errorf("issuer already exists: %s", issuerID)
	}

	issuer := models.IssuerOrganization{
		IssuerID:     issuerID,
		Organization: organization,
		MSPID:        mspID,
		IssuerType:   issuerType,
		Active:       true,
		RegisteredAt: utils.NowUTC(),
	}

	payload, err := json.Marshal(issuer)
	if err != nil {
		return fmt.Errorf("marshal failed: %w", err)
	}

	return repo.Put(ctx, key, payload)
}

func (c *IssuerContract) GetIssuer(
	ctx contractapi.TransactionContextInterface,
	issuerID string,
) (*models.IssuerOrganization, error) {

	if err := utils.RequireNonEmpty("issuerID", issuerID); err != nil {
		return nil, err
	}

	repo := repository.NewLedgerRepository()
	key := utils.IssuerKey(issuerID)

	data, err := repo.Get(ctx, key)
	if err != nil {
		return nil, err
	}

	if data == nil {
		return nil, fmt.Errorf("issuer not found: %s", issuerID)
	}

	var issuer models.IssuerOrganization
	if err := json.Unmarshal(data, &issuer); err != nil {
		return nil, fmt.Errorf("unmarshal failed: %w", err)
	}

	return &issuer, nil
}

func (c *IssuerContract) IsIssuerAuthorized(
	ctx contractapi.TransactionContextInterface,
	issuerID string,
) (bool, error) {

	issuer, err := c.GetIssuer(ctx, issuerID)
	if err != nil {
		return false, err
	}

	if !issuer.Active {
		return false, nil
	}

	return true, nil
}
