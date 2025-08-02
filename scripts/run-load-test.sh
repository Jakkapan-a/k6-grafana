#!/bin/bash

# Start infrastructure
echo "Starting InfluxDB and Grafana..."
docker-compose up -d influxdb grafana

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 30

# Run k6 test with InfluxDB output
echo "Running k6 load test..."
docker-compose run --rm k6 k6 run test.ts --out influxdb=http://influxdb:8086/k6

echo "Test completed! Check Grafana dashboard at http://localhost:3033"
echo "Username: admin, Password: admin"
