# PowerShell script for Windows
Write-Host "Starting InfluxDB and Grafana..." -ForegroundColor Green
docker-compose up -d influxdb grafana

Write-Host "Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "Running k6 load test..." -ForegroundColor Green
docker-compose run --rm k6 k6 run test.ts --out influxdb=http://influxdb:8086/k6

Write-Host "Test completed! Check Grafana dashboard at http://localhost:3033" -ForegroundColor Cyan
Write-Host "Username: admin, Password: admin" -ForegroundColor Cyan
