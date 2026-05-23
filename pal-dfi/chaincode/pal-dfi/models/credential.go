package models

type FinancialCredential struct {
    CredentialID     string `json:"credentialId"`
    CitizenID        string `json:"citizenId"`
    CredentialType   string `json:"credentialType"`
    IssuerID         string `json:"issuerId"`
    IssuedAt         string `json:"issuedAt"`
    ExpiresAt        string `json:"expiresAt"`
    Status           string `json:"status"`
    MetadataHash     string `json:"metadataHash"`
    RevocationReason string `json:"revocationReason"`
}
