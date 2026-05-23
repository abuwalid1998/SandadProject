package models

type BlockchainTransaction struct {
	Time        string `json:"time"`
	Channel     string `json:"channel"`
	TxID        string `json:"txId"`
	Org         string `json:"org"`
	Function    string `json:"function"`
	Status      string `json:"status"`
	BlockNumber uint64 `json:"blockNumber"`
}
