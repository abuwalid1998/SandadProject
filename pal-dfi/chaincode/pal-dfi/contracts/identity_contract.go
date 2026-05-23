package contracts

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/paldfi/chaincode/pal-dfi/models"
	"github.com/paldfi/chaincode/pal-dfi/repository"
	"github.com/paldfi/chaincode/pal-dfi/utils"
)

const CitizenRegistrarMSP = "MOIMSP"

type IdentityContract struct {
	contractapi.Contract
}

func (c *IdentityContract) RegisterCitizen(
	ctx contractapi.TransactionContextInterface,
	citizenID string,
	nationalID string,
	fullName string,
	dateOfBirth string,
	mobileNumber string,
	email string,
	address string,
) error {

	if err := utils.RequireMSP(ctx, CitizenRegistrarMSP); err != nil {
		return err
	}

	fields := map[string]string{
		"citizenID":    citizenID,
		"nationalID":   nationalID,
		"fullName":     fullName,
		"dateOfBirth":  dateOfBirth,
		"mobileNumber": mobileNumber,
	}

	for k, v := range fields {
		if err := utils.RequireNonEmpty(k, v); err != nil {
			return err
		}
	}

	repo := repository.NewLedgerRepository()
	key := utils.CitizenKey(citizenID)

	existing, err := repo.Get(ctx, key)
	if err != nil {
		return err
	}

	if existing != nil {
		return fmt.Errorf("citizen already exists: %s", citizenID)
	}

	citizen := models.CitizenIdentity{
		CitizenID:      citizenID,
		NationalID:     nationalID,
		FullName:       fullName,
		DateOfBirth:    dateOfBirth,
		MobileNumber:   mobileNumber,
		Email:          email,
		Address:        address,
		Status:         "ACTIVE",
		IssuedBy:       CitizenRegistrarMSP,
		CreatedAt:      utils.NowUTC(),
		UpdatedAt:      utils.NowUTC(),
		CredentialRefs: []string{},
	}

	payload, err := json.Marshal(citizen)
	if err != nil {
		return fmt.Errorf("marshal failed: %w", err)
	}

	return repo.Put(ctx, key, payload)
}

func (c *IdentityContract) GetCitizen(
	ctx contractapi.TransactionContextInterface,
	citizenID string,
) (*models.CitizenIdentity, error) {

	if err := utils.RequireNonEmpty("citizenID", citizenID); err != nil {
		return nil, err
	}

	repo := repository.NewLedgerRepository()
	key := utils.CitizenKey(citizenID)

	data, err := repo.Get(ctx, key)
	if err != nil {
		return nil, err
	}

	if data == nil {
		return nil, fmt.Errorf("citizen not found: %s", citizenID)
	}

	var citizen models.CitizenIdentity
	if err := json.Unmarshal(data, &citizen); err != nil {
		return nil, fmt.Errorf("unmarshal failed: %w", err)
	}

	return &citizen, nil
}

func (c *IdentityContract) UpdateCitizen(
	ctx contractapi.TransactionContextInterface,
	citizenID string,
	mobileNumber string,
	email string,
	address string,
	status string,
) error {

	if err := utils.RequireMSP(ctx, CitizenRegistrarMSP); err != nil {
		return err
	}

	citizen, err := c.GetCitizen(ctx, citizenID)
	if err != nil {
		return err
	}

	if mobileNumber != "" {
		citizen.MobileNumber = mobileNumber
	}

	if email != "" {
		citizen.Email = email
	}

	if address != "" {
		citizen.Address = address
	}

	if status != "" {
		citizen.Status = status
	}

	citizen.UpdatedAt = utils.NowUTC()

	payload, err := json.Marshal(citizen)
	if err != nil {
		return fmt.Errorf("marshal failed: %w", err)
	}

	repo := repository.NewLedgerRepository()
	return repo.Put(ctx, utils.CitizenKey(citizenID), payload)
}
