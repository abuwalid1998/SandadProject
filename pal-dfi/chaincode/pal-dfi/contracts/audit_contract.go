package contracts

import (
	"encoding/json"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/paldfi/chaincode/pal-dfi/models"
	"github.com/paldfi/chaincode/pal-dfi/repository"
	"github.com/paldfi/chaincode/pal-dfi/utils"
)

type AuditContract struct {
	contractapi.Contract
}

func (c *AuditContract) GetAuditTrail(
	ctx contractapi.TransactionContextInterface,
	credentialID string,
) ([]*models.VerificationAudit, error) {

	iter, err := ctx.GetStub().GetStateByPartialCompositeKey(
		utils.AuditCredentialIndex,
		[]string{credentialID},
	)
	if err != nil {
		return nil, err
	}
	defer iter.Close()

	repo := repository.NewLedgerRepository()
	var audits []*models.VerificationAudit

	for iter.HasNext() {
		entry, err := iter.Next()
		if err != nil {
			return nil, err
		}

		_, parts, err := ctx.GetStub().SplitCompositeKey(entry.Key)
		if err != nil {
			return nil, err
		}

		auditID := parts[1]

		data, err := repo.Get(ctx, utils.AuditKey(auditID))
		if err != nil {
			return nil, err
		}

		var audit models.VerificationAudit
		if err := json.Unmarshal(data, &audit); err != nil {
			return nil, err
		}

		audits = append(audits, &audit)
	}

	return audits, nil
}
