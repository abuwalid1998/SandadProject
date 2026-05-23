package models

type IssuerOrganization struct {
	IssuerID     string `json:"issuerId"`
	Organization string `json:"organization"`
	MSPID        string `json:"mspId"`
	IssuerType   string `json:"issuerType"`
	Active       bool   `json:"active"`
	RegisteredAt string `json:"registeredAt"`
}
