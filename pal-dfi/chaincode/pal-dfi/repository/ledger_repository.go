package repository

import (
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type LedgerRepository struct{}

func NewLedgerRepository() *LedgerRepository {
	return &LedgerRepository{}
}

func (r *LedgerRepository) Put(
	ctx contractapi.TransactionContextInterface,
	key string,
	value []byte,
) error {
	return ctx.GetStub().PutState(key, value)
}

func (r *LedgerRepository) Get(
	ctx contractapi.TransactionContextInterface,
	key string,
) ([]byte, error) {
	data, err := ctx.GetStub().GetState(key)
	if err != nil {
		return nil, fmt.Errorf("ledger read failed: %w", err)
	}
	return data, nil
}

func (r *LedgerRepository) Delete(
	ctx contractapi.TransactionContextInterface,
	key string,
) error {
	return ctx.GetStub().DelState(key)
}
