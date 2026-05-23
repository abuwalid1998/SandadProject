package fabric

import (
	"context"
	"log"
	"time"

	"pal-dfi-monitor/models"
)

func StartListener() {
	gateway, err := ConnectGateway()
	if err != nil {
		log.Println("Fabric connect failed:", err)
		return
	}

	network := gateway.GetNetwork("identity-channel")

	events, err := network.BlockEvents(context.Background())
	if err != nil {
		log.Println(err)
		return
	}

	log.Println("Fabric listener started")

	for event := range events {
		for _, tx := range event.Transactions {
			AddTransaction(models.BlockchainTransaction{
				Time:        time.Now().Format("15:04:05"),
				Channel:     "identity-channel",
				TxID:        tx.TransactionID,
				Org:         "PMAMSP",
				Function:    "CHAINCODE_TX",
				Status:      tx.ValidationCode.String(),
				BlockNumber: event.BlockNumber,
			})
		}
	}
}
