package models

type CitizenIdentity struct {
    CitizenID      string   `json:"citizenId"`
    NationalID     string   `json:"nationalId"`
    FullName       string   `json:"fullName"`
    DateOfBirth    string   `json:"dateOfBirth"`
    MobileNumber   string   `json:"mobileNumber"`
    Email          string   `json:"email"`
    Address        string   `json:"address"`
    Status         string   `json:"status"`
    IssuedBy       string   `json:"issuedBy"`
    CreatedAt      string   `json:"createdAt"`
    UpdatedAt      string   `json:"updatedAt"`
    CredentialRefs []string `json:"credentialRefs"`
}
