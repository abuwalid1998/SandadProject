package fabric

import (
	"sync"

	"pal-dfi-monitor/models"
)

var txCache []models.BlockchainTransaction
var mu sync.Mutex

func AddTransaction(tx models.BlockchainTransaction) {
	mu.Lock()
	defer mu.Unlock()

	txCache = append([]models.BlockchainTransaction{tx}, txCache...)

	if len(txCache) > 100 {
		txCache = txCache[:100]
	}
}

func GetTransactionCache() []models.BlockchainTransaction {
	mu.Lock()
	defer mu.Unlock()

	return txCache
}
