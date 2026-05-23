@echo off
set ROOT=pal-dfi

echo Creating project structure...

mkdir %ROOT%
cd %ROOT%

mkdir network
mkdir network\fabric-ca
mkdir network\organizations
mkdir network\channel-artifacts
mkdir network\config
mkdir network\scripts

mkdir chaincode
mkdir chaincode\identitycc

mkdir apps
mkdir apps\moi
mkdir apps\moi\config
mkdir apps\moi\db
mkdir apps\moi\handlers
mkdir apps\moi\services
mkdir apps\moi\fabric

mkdir apps\pma
mkdir apps\pma\config
mkdir apps\pma\db
mkdir apps\pma\handlers
mkdir apps\pma\services
mkdir apps\pma\fabric

mkdir apps\jawwal
mkdir apps\jawwal\config
mkdir apps\jawwal\db
mkdir apps\jawwal\handlers
mkdir apps\jawwal\services
mkdir apps\jawwal\fabric

mkdir databases
mkdir databases\moi
mkdir databases\pma
mkdir databases\jawwal

mkdir connection-profiles
mkdir docs
mkdir scripts

type nul > docker-compose.yaml
type nul > .env

type nul > apps\moi\Dockerfile
type nul > apps\pma\Dockerfile
type nul > apps\jawwal\Dockerfile

type nul > apps\moi\.env.example
type nul > apps\pma\.env.example
type nul > apps\jawwal\.env.example

echo Structure created successfully.
pause