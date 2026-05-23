package utils

const (
	CitizenPrefix    = "CITIZEN"
	CredentialPrefix = "CREDENTIAL"
	AuditPrefix      = "AUDIT"
	IssuerPrefix     = "ISSUER"

	CredentialCitizenIndex = "credential~citizen"
	AuditCredentialIndex   = "audit~credential"
)

func CitizenKey(id string) string {
	return CitizenPrefix + ":" + id
}

func CredentialKey(id string) string {
	return CredentialPrefix + ":" + id
}

func AuditKey(id string) string {
	return AuditPrefix + ":" + id
}

func IssuerKey(id string) string {
	return IssuerPrefix + ":" + id
}
