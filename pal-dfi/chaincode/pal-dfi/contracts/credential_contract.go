package contracts

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"

	"github.com/paldfi/chaincode/pal-dfi/models"
	"github.com/paldfi/chaincode/pal-dfi/repository"
	"github.com/paldfi/chaincode/pal-dfi/utils"
)

type CredentialContract struct {
	contractapi.Contract
}

func (c *CredentialContract) IssueCredential(
	ctx contractapi.TransactionContextInterface,
	citizenID string,
	credentialType string,
	issuerID string,
	expiresAt string,
	metadataHash string,
) error {

	if err := utils.RequireNonEmpty("citizenID", citizenID); err != nil {
		return err
	}

	if err := utils.RequireNonEmpty("credentialType", credentialType); err != nil {
		return err
	}

	if err := utils.RequireNonEmpty("issuerID", issuerID); err != nil {
		return err
	}

	repo := repository.NewLedgerRepository()

	identityContract := &IdentityContract{}
	issuerContract := &IssuerContract{}

	_, err := identityContract.GetCitizen(ctx, citizenID)
	if err != nil {
		return err
	}

	issuer, err := issuerContract.GetIssuer(ctx, issuerID)
	if err != nil {
		return err
	}

	clientMSP, err := utils.GetClientMSPID(ctx)
	if err != nil {
		return err
	}

	if clientMSP != issuer.MSPID {
		return fmt.Errorf("unauthorized issuer MSP")
	}

	if !issuer.Active {
		return fmt.Errorf("issuer inactive")
	}

	credentialID := utils.DeterministicID(
		citizenID,
		credentialType,
		issuerID,
		utils.NowUTC(),
	)

	credential := models.FinancialCredential{
		CredentialID:     credentialID,
		CitizenID:        citizenID,
		CredentialType:   credentialType,
		IssuerID:         issuerID,
		IssuedAt:         utils.NowUTC(),
		ExpiresAt:        expiresAt,
		Status:           "ACTIVE",
		MetadataHash:     metadataHash,
		RevocationReason: "",
	}

	payload, err := json.Marshal(credential)
	if err != nil {
		return err
	}

	err = repo.Put(ctx, utils.CredentialKey(credentialID), payload)
	if err != nil {
		return err
	}

	indexKey, err := ctx.GetStub().CreateCompositeKey(
		utils.CredentialCitizenIndex,
		[]string{citizenID, credentialID},
	)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(indexKey, []byte{0})
}

func (c *CredentialContract) VerifyCredential(
	ctx contractapi.TransactionContextInterface,
	credentialID string,
	requestReference string,
) (bool, error) {

	repo := repository.NewLedgerRepository()

	data, err := repo.Get(ctx, utils.CredentialKey(credentialID))
	if err != nil {
		return false, err
	}

	if data == nil {
		return false, fmt.Errorf("credential not found")
	}

	var credential models.FinancialCredential
	if err := json.Unmarshal(data, &credential); err != nil {
		return false, err
	}

	valid := credential.Status == "ACTIVE"

	if valid && credential.ExpiresAt != "" {
		expiry, err := utils.ParseRFC3339(credential.ExpiresAt)
		if err == nil && time.Now().UTC().After(expiry) {
			valid = false
		}
	}

	clientMSP, err := utils.GetClientMSPID(ctx)
	if err != nil {
		return false, err
	}

	auditID := utils.DeterministicID(
		credentialID,
		requestReference,
		utils.NowUTC(),
	)

	audit := models.VerificationAudit{
		AuditID:            auditID,
		CredentialID:       credentialID,
		VerifierOrg:        clientMSP,
		VerificationResult: valid,
		Timestamp:          utils.NowUTC(),
		RequestReference:   requestReference,
	}

	auditPayload, err := json.Marshal(audit)
	if err != nil {
		return false, err
	}

	err = repo.Put(ctx, utils.AuditKey(auditID), auditPayload)
	if err != nil {
		return false, err
	}

	auditIndex, err := ctx.GetStub().CreateCompositeKey(
		utils.AuditCredentialIndex,
		[]string{credentialID, auditID},
	)
	if err != nil {
		return false, err
	}

	err = ctx.GetStub().PutState(auditIndex, []byte{0})
	if err != nil {
		return false, err
	}

	return valid, nil
}

func (c *CredentialContract) RevokeCredential(
	ctx contractapi.TransactionContextInterface,
	credentialID string,
	reason string,
) error {

	repo := repository.NewLedgerRepository()

	data, err := repo.Get(ctx, utils.CredentialKey(credentialID))
	if err != nil {
		return err
	}

	if data == nil {
		return fmt.Errorf("credential not found")
	}

	var credential models.FinancialCredential
	if err := json.Unmarshal(data, &credential); err != nil {
		return err
	}

	issuerContract := &IssuerContract{}
	issuer, err := issuerContract.GetIssuer(ctx, credential.IssuerID)
	if err != nil {
		return err
	}

	clientMSP, err := utils.GetClientMSPID(ctx)
	if err != nil {
		return err
	}

	if clientMSP != issuer.MSPID {
		return fmt.Errorf("only issuing org may revoke")
	}

	credential.Status = "REVOKED"
	credential.RevocationReason = reason

	payload, err := json.Marshal(credential)
	if err != nil {
		return err
	}

	return repo.Put(ctx, utils.CredentialKey(credentialID), payload)
}

func (c *CredentialContract) GetCitizenCredentials(
	ctx contractapi.TransactionContextInterface,
	citizenID string,
) ([]*models.FinancialCredential, error) {

	iter, err := ctx.GetStub().GetStateByPartialCompositeKey(
		utils.CredentialCitizenIndex,
		[]string{citizenID},
	)
	if err != nil {
		return nil, err
	}
	defer iter.Close()

	repo := repository.NewLedgerRepository()
	var credentials []*models.FinancialCredential

	for iter.HasNext() {
		entry, err := iter.Next()
		if err != nil {
			return nil, err
		}

		_, parts, err := ctx.GetStub().SplitCompositeKey(entry.Key)
		if err != nil {
			return nil, err
		}

		credentialID := parts[1]

		data, err := repo.Get(ctx, utils.CredentialKey(credentialID))
		if err != nil {
			return nil, err
		}

		var credential models.FinancialCredential
		if err := json.Unmarshal(data, &credential); err != nil {
			return nil, err
		}

		credentials = append(credentials, &credential)
	}

	return credentials, nil
}
