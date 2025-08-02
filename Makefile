# K6 Load Testing Makefile

.PHONY: help start stop restart logs test health clean rebuild

# Default target
help:
	@echo "K6 Load Testing Commands:"
	@echo "========================"
	@echo "make start      - Start all services"
	@echo "make stop       - Stop all services"
	@echo "make restart    - Restart all services"
	@echo "make logs       - View all logs"
	@echo "make test       - Run simple load test"
	@echo "make test-load  - Run load test with metrics"
	@echo "make health     - Check service health"
	@echo "make clean      - Clean up volumes and containers"
	@echo "make rebuild    - Rebuild everything from scratch"

# Start services
start:
	@echo "🚀 Starting K6 Load Testing Stack..."
	docker-compose up -d
	@echo "✅ Services started!"
	@echo "📈 Grafana: http://localhost:3033 (admin/admin)"
	@echo "📊 InfluxDB: http://localhost:8086"

# Stop services
stop:
	@echo "🛑 Stopping services..."
	docker-compose down

# Restart services
restart:
	@echo "🔄 Restarting services..."
	docker-compose restart

# View logs
logs:
	docker-compose logs -f

# Health check
health:
	@echo "🔍 Checking service health..."
	@powershell.exe -ExecutionPolicy Bypass -File "./scripts/health-check.ps1"

# Simple test
test:
	@echo "🧪 Running simple load test..."
	docker-compose exec k6 k6 run simple-test.ts --out influxdb=http://influxdb:8086/k6

# Load test with metrics
test-load:
	@echo "📊 Running load test with metrics..."
	docker-compose exec k6 k6 run test.ts --out influxdb=http://influxdb:8086/k6

# Stress test
test-stress:
	@echo "💪 Running stress test..."
	docker-compose exec k6 k6 run stress-test.ts --out influxdb=http://influxdb:8086/k6

# Clean up
clean:
	@echo "🧹 Cleaning up..."
	docker-compose down -v
	docker system prune -f

# Rebuild everything
rebuild: clean start
	@echo "🔧 Rebuild completed!"
