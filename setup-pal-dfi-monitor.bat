@echo off
setlocal

set ROOT=pal-dfi-monitor

echo ==========================================
echo Creating %ROOT% monitoring platform...
echo ==========================================

if exist %ROOT% (
    echo Folder %ROOT% already exists.
    pause
    exit /b 1
)

mkdir %ROOT%
cd %ROOT%

REM ==========================================
REM ROOT FILES
REM ==========================================
type nul > docker-compose.yaml
type nul > .env
type nul > README.md

REM ==========================================
REM PROMETHEUS
REM ==========================================
mkdir prometheus
type nul > prometheus\prometheus.yml

REM ==========================================
REM GRAFANA
REM ==========================================
mkdir grafana
mkdir grafana\provisioning
mkdir grafana\provisioning\datasources
mkdir grafana\provisioning\dashboards

type nul > grafana\provisioning\datasources\prometheus.yml
type nul > grafana\provisioning\dashboards\dashboard.yml

REM ==========================================
REM HYPERLEDGER EXPLORER
REM ==========================================
mkdir explorer
mkdir explorer\connection-profiles
mkdir explorer\db
mkdir explorer\wallet
mkdir explorer\config

type nul > explorer\config.json
type nul > explorer\connection-profiles\pma-network.json

REM ==========================================
REM MONITOR API (GO)
REM ==========================================
mkdir monitor-api
mkdir monitor-api\api
mkdir monitor-api\models
mkdir monitor-api\services
mkdir monitor-api\fabric
mkdir monitor-api\docker
mkdir monitor-api\utils
mkdir monitor-api\config

type nul > monitor-api\Dockerfile
type nul > monitor-api\go.mod
type nul > monitor-api\go.sum
type nul > monitor-api\main.go
type nul > monitor-api\routes.go

type nul > monitor-api\api\health.go
type nul > monitor-api\api\containers.go
type nul > monitor-api\api\transactions.go
type nul > monitor-api\api\metrics.go

type nul > monitor-api\models\container.go
type nul > monitor-api\models\transaction.go
type nul > monitor-api\models\metrics.go

type nul > monitor-api\services\docker_stats.go
type nul > monitor-api\services\metrics_service.go

type nul > monitor-api\fabric\listener.go
type nul > monitor-api\fabric\gateway.go
type nul > monitor-api\fabric\events.go

type nul > monitor-api\docker\client.go

type nul > monitor-api\utils\helpers.go

type nul > monitor-api\config\config.go

REM ==========================================
REM MONITOR UI
REM ==========================================
mkdir monitor-ui
mkdir monitor-ui\assets
mkdir monitor-ui\assets\css
mkdir monitor-ui\assets\js
mkdir monitor-ui\assets\img
mkdir monitor-ui\components

type nul > monitor-ui\index.html
type nul > monitor-ui\assets\css\style.css
type nul > monitor-ui\assets\js\app.js
type nul > monitor-ui\assets\js\api.js
type nul > monitor-ui\assets\js\dashboard.js
type nul > monitor-ui\components\navbar.html
type nul > monitor-ui\components\sidebar.html

REM ==========================================
REM SCRIPTS
REM ==========================================
mkdir scripts

type nul > scripts\start-monitor.bat
type nul > scripts\stop-monitor.bat
type nul > scripts\reset-monitor.bat

REM ==========================================
REM LOGS
REM ==========================================
mkdir logs
mkdir logs\monitor-api
mkdir logs\explorer

REM ==========================================
REM DOCS
REM ==========================================
mkdir docs

type nul > docs\architecture.md
type nul > docs\api-endpoints.md

echo.
echo ==========================================
echo pal-dfi-monitor structure created successfully
echo ==========================================
echo.
echo Location:
cd
echo.
pause