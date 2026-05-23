package models

type VerificationAudit struct {
    AuditID             string `json:"auditId"`
    CredentialID        string `json:"credentialId"`
    VerifierOrg         string `json:"verifierOrg"`
    VerificationResult  bool   `json:"verificationResult"`
    Timestamp           string `json:"timestamp"`
    RequestReference    string `json:"requestReference"`
}
