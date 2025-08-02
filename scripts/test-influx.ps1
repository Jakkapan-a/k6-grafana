# PowerShell script to test InfluxDB connection and show available data
Write-Host "🔍 Testing InfluxDB connection and data..." -ForegroundColor Cyan

# Test InfluxDB ping
Write-Host "`n📊 Testing InfluxDB ping..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8086/ping" -TimeoutSec 5
    Write-Host "✅ InfluxDB is responding" -ForegroundColor Green
} catch {
    Write-Host "❌ InfluxDB not responding: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Show databases
Write-Host "`n📋 Available databases:" -ForegroundColor Yellow
try {
    docker-compose exec -T influxdb influx -execute "SHOW DATABASES"
} catch {
    Write-Host "❌ Could not list databases" -ForegroundColor Red
}

# Show measurements in k6 database
Write-Host "`n📈 Measurements in k6 database:" -ForegroundColor Yellow
try {
    docker-compose exec -T influxdb influx -database k6 -execute "SHOW MEASUREMENTS"
} catch {
    Write-Host "❌ Could not list measurements" -ForegroundColor Red
}

# Show sample data from vus table (if exists)
Write-Host "`n👥 Sample VU data:" -ForegroundColor Yellow
try {
    docker-compose exec -T influxdb influx -database k6 -execute "SELECT * FROM vus LIMIT 5"
} catch {
    Write-Host "⚠️ No VU data found (run a test first)" -ForegroundColor Yellow
}

# Show sample data from http_reqs table (if exists)
Write-Host "`n🌐 Sample HTTP request data:" -ForegroundColor Yellow
try {
    docker-compose exec -T influxdb influx -database k6 -execute "SELECT * FROM http_reqs LIMIT 5"
} catch {
    Write-Host "⚠️ No HTTP request data found (run a test first)" -ForegroundColor Yellow
}

Write-Host "`n💡 To generate test data, run: npm run test:simple" -ForegroundColor Cyan
