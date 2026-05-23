@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo PAL-DFI Chaincode Bootstrap
echo Hyperledger Fabric Go Project Generator
echo ==========================================

REM Project settings
set PROJECT_NAME=pal-dfi
set MODULE_NAME=github.com/paldfi/chaincode/pal-dfi

REM Verify Go installation
where go >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Go is not installed or not in PATH.
    pause
    exit /b 1
)

echo [OK] Go detected

REM Move to chaincode folder
if not exist chaincode (
    mkdir chaincode
)

cd chaincode

REM Create project root
if exist %PROJECT_NAME% (
    echo [WARNING] Project folder already exists.
    pause
    exit /b 1
)

mkdir %PROJECT_NAME%
cd %PROJECT_NAME%

echo Creating folder structure...

mkdir cmd
mkdir contracts
mkdir models
mkdir repository
mkdir utils
mkdir docs
mkdir test

echo Creating starter files...

type nul > cmd\main.go

type nul > contracts\identity_contract.go
type nul > contracts\issuer_contract.go
type nul > contracts\credential_contract.go
type nul > contracts\audit_contract.go

type nul > models\citizen.go
type nul > models\credential.go
type nul > models\issuer.go
type nul > models\audit.go

type nul > repository\ledger_repository.go

type nul > utils\keys.go
type nul > utils\validation.go
type nul > utils\timestamps.go
type nul > utils\auth.go
type nul > utils\errors.go

type nul > README.md
type nul > .gitignore

echo Initializing Go module...
go mod init %MODULE_NAME%
if %errorlevel% neq 0 (
    echo [ERROR] Failed to initialize Go module.
    pause
    exit /b 1
)

echo Installing Hyperledger Fabric dependencies...
go get github.com/hyperledger/fabric-contract-api-go/contractapi
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install Fabric dependencies.
    pause
    exit /b 1
)

echo Resolving dependencies...
go mod tidy

echo Writing .gitignore...

(
echo vendor/
echo *.exe
echo *.test
echo *.out
echo coverage.*
echo .idea/
echo .vscode/
) > .gitignore

echo Writing starter main.go...

(
echo package main
echo.
echo import ^(
echo     "log"
echo.
echo     "github.com/hyperledger/fabric-contract-api-go/contractapi"
echo     "github.com/paldfi/chaincode/pal-dfi/contracts"
echo ^)
echo.
echo func main^(^) ^{
echo     cc, err := contractapi.NewChaincode^(
echo         new^(contracts.IdentityContract^),
echo         new^(contracts.IssuerContract^),
echo         new^(contracts.CredentialContract^),
echo         new^(contracts.AuditContract^),
echo     ^)
echo.
echo     if err != nil ^{
echo         log.Panicf^("chaincode init failed: %%v", err^)
echo     ^}
echo.
echo     if err := cc.Start^(^); err != nil ^{
echo         log.Panicf^("chaincode start failed: %%v", err^)
echo     ^}
echo ^}
) > cmd\main.go

echo Writing placeholder contract files...

(
echo package contracts
echo.
echo import "github.com/hyperledger/fabric-contract-api-go/contractapi"
echo.
echo type IdentityContract struct ^{
echo     contractapi.Contract
echo ^}
) > contracts\identity_contract.go

(
echo package contracts
echo.
echo import "github.com/hyperledger/fabric-contract-api-go/contractapi"
echo.
echo type IssuerContract struct ^{
echo     contractapi.Contract
echo ^}
) > contracts\issuer_contract.go

(
echo package contracts
echo.
echo import "github.com/hyperledger/fabric-contract-api-go/contractapi"
echo.
echo type CredentialContract struct ^{
echo     contractapi.Contract
echo ^}
) > contracts\credential_contract.go

(
echo package contracts
echo.
echo import "github.com/hyperledger/fabric-contract-api-go/contractapi"
echo.
echo type AuditContract struct ^{
echo     contractapi.Contract
echo ^}
) > contracts\audit_contract.go

echo Writing model files...

(
echo package models
echo.
echo type CitizenIdentity struct ^{
echo     CitizenID      string   `json:"citizenId"`
echo     NationalID     string   `json:"nationalId"`
echo     FullName       string   `json:"fullName"`
echo     DateOfBirth    string   `json:"dateOfBirth"`
echo     MobileNumber   string   `json:"mobileNumber"`
echo     Email          string   `json:"email"`
echo     Address        string   `json:"address"`
echo     Status         string   `json:"status"`
echo     IssuedBy       string   `json:"issuedBy"`
echo     CreatedAt      string   `json:"createdAt"`
echo     UpdatedAt      string   `json:"updatedAt"`
echo     CredentialRefs []string `json:"credentialRefs"`
echo ^}
) > models\citizen.go

(
echo package models
echo.
echo type FinancialCredential struct ^{
echo     CredentialID     string `json:"credentialId"`
echo     CitizenID        string `json:"citizenId"`
echo     CredentialType   string `json:"credentialType"`
echo     IssuerID         string `json:"issuerId"`
echo     IssuedAt         string `json:"issuedAt"`
echo     ExpiresAt        string `json:"expiresAt"`
echo     Status           string `json:"status"`
echo     MetadataHash     string `json:"metadataHash"`
echo     RevocationReason string `json:"revocationReason"`
echo ^}
) > models\credential.go

(
echo package models
echo.
echo type IssuerOrganization struct ^{
echo     IssuerID      string `json:"issuerId"`
echo     Organization  string `json:"organization"`
echo     MSPID         string `json:"mspId"`
echo     IssuerType    string `json:"issuerType"`
echo     Active        bool   `json:"active"`
echo     RegisteredAt  string `json:"registeredAt"`
echo ^}
) > models\issuer.go

(
echo package models
echo.
echo type VerificationAudit struct ^{
echo     AuditID             string `json:"auditId"`
echo     CredentialID        string `json:"credentialId"`
echo     VerifierOrg         string `json:"verifierOrg"`
echo     VerificationResult  bool   `json:"verificationResult"`
echo     Timestamp           string `json:"timestamp"`
echo     RequestReference    string `json:"requestReference"`
echo ^}
) > models\audit.go

echo Writing utilities...

(
echo package utils
echo.
echo func CitizenKey^(id string^) string ^{
echo     return "CITIZEN:" + id
echo ^}
echo.
echo func CredentialKey^(id string^) string ^{
echo     return "CREDENTIAL:" + id
echo ^}
echo.
echo func AuditKey^(id string^) string ^{
echo     return "AUDIT:" + id
echo ^}
echo.
echo func IssuerKey^(id string^) string ^{
echo     return "ISSUER:" + id
echo ^}
) > utils\keys.go

(
echo package utils
) > utils\validation.go

(
echo package utils
) > utils\timestamps.go

(
echo package utils
) > utils\auth.go

(
echo package utils
) > utils\errors.go

(
echo package repository
) > repository\ledger_repository.go

echo Testing build...
go build ./...
if %errorlevel% neq 0 (
    echo [WARNING] Build check failed. Structure created, but dependencies may need review.
) else (
    echo [OK] Build successful.
)

echo.
echo ==========================================
echo PAL-DFI bootstrap completed successfully
echo Location:
echo chaincode\pal-dfi
echo ==========================================
pause