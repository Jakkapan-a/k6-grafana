# K6 Load Testing with InfluxDB & Grafana

โปรเจกต์นี้เป็น Load Testing Suite ที่ใช้ K6, InfluxDB และ Grafana เพื่อทดสอบประสิทธิภาพของเว็บแอปพลิเคชัน

## 🚀 Features

- **K6**: Load testing tool ที่เขียนด้วย TypeScript
- **InfluxDB v2**: Time-series database สำหรับเก็บผลลัพธ์การทดสอบ
- **Grafana**: Dashboard สำหรับแสดงผลการทดสอบแบบ Real-time
- **Docker Compose**: Setup และ Deploy แบบ One-click

## 📋 Prerequisites

- Docker และ Docker Compose
- Node.js (สำหรับ TypeScript development)

## 🛠️ Installation

1. Clone repository:
```bash
git clone <your-repo-url>
cd k6-load-testing
```

2. Install dependencies:
```bash
npm install
```

3. Start infrastructure:
```bash
npm run start
# หรือ
docker-compose up -d
```

## 🔧 Configuration

### แก้ไข Target URL

แก้ไขไฟล์ `k6/test.ts`, `k6/simple-test.ts`, หรือ `k6/stress-test.ts`:

```typescript
const baseUrl = 'http://your-target-url:port';
```

### ปรับแต่งการทดสอบ

แก้ไข `options` ในไฟล์ test script:

```typescript
export const options = {
  stages: [
    { duration: '30s', target: 10 }, // Ramp up to 10 users
    { duration: '1m', target: 50 },  // Stay at 50 users
    { duration: '30s', target: 0 },  // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% requests < 500ms
    http_req_failed: ['rate<0.1'],    // Error rate < 10%
  },
};
```

## 🎯 Running Tests

### วิธีที่ 1: ใช้ npm scripts

```bash
# Simple test (10 VUs for 30s)
npm run test:simple

# Load test (stages with custom metrics)
npm run test:load

# Stress test (long-running test)
npm run test:stress
```

### วิธีที่ 2: ใช้ PowerShell script (Windows)

```powershell
.\scripts\run-load-test.ps1
```

### วิธีที่ 3: ใช้ Docker Compose โดยตรง

```bash
# เริ่ม infrastructure
docker-compose up -d influxdb grafana

# รอให้ services พร้อม (30 วินาที)
# รัน test
docker-compose run --rm k6 k6 run test.ts
```

### วิธีที่ 4: Manual k6 commands

```bash
# เข้าไปใน k6 container
docker-compose exec k6 sh

# รัน test ต่างๆ
k6 run simple-test.ts
k6 run test.ts
k6 run stress-test.ts
```

## 📊 Monitoring & Dashboards

### Grafana Dashboard

1. เปิด browser ไปที่: http://localhost:3033
2. Login:
   - Username: `admin`
   - Password: `admin`
3. InfluxDB datasource จะถูก configure อัตโนมัติ
4. Import K6 dashboard หรือสร้าง dashboard ใหม่

### InfluxDB

- URL: http://localhost:8086
- Organization: `k6-org`
- Bucket: `k6`
- Token: `k6-token-1234567890`

## 📁 Project Structure

```
├── docker-compose.yaml           # Docker services configuration
├── package.json                  # Node.js dependencies and scripts
├── tsconfig.json                # TypeScript configuration
├── grafana/
│   └── provisioning/
│       ├── datasources/          # Auto-configured datasources
│       └── dashboards/           # Dashboard provisioning
├── k6/                          # K6 test scripts
│   ├── test.ts                  # Main load test with stages
│   ├── simple-test.ts           # Simple load test
│   ├── stress-test.ts           # Long-running stress test
│   └── tsconfig.json            # K6 TypeScript config
└── scripts/
    ├── run-load-test.ps1        # PowerShell script (Windows)
    └── run-load-test.sh         # Bash script (Linux/Mac)
```

## 🧪 Test Scripts Explained

### 1. `simple-test.ts`
- เหมาะสำหรับ Quick smoke test
- 10 VUs เป็นเวลา 30 วินาที
- Thresholds: 95% < 200ms, Error rate < 5%

### 2. `test.ts` (Main Load Test)
- Realistic load testing scenario
- Stages: Ramp up → Load → Peak → Ramp down
- Multiple endpoints testing
- Custom metrics และ detailed checks

### 3. `stress-test.ts`
- Long-running stress test (20 นาที)
- เพื่อหา breaking point ของระบบ
- สำหรับ Endurance testing

## 📈 Metrics & Thresholds

### Built-in Metrics
- `http_req_duration`: Response time
- `http_req_failed`: Failed request rate
- `http_req_rate`: Request rate
- `vus`: Active virtual users

### Custom Metrics
- `errors`: Custom error rate
- `response_time`: Custom response time trend
- `requests`: Total request counter

### Thresholds Examples
```typescript
thresholds: {
  http_req_duration: ['p(95)<500', 'p(99)<1000'],
  http_req_failed: ['rate<0.1'],
  errors: ['rate<0.05'],
}
```

## 🛠️ Management Commands

```bash
# Start all services
npm run start

# Stop all services
npm run stop

# Restart services
npm run restart

# View logs
npm run logs

# View specific service logs
docker-compose logs -f k6
docker-compose logs -f grafana
docker-compose logs -f influxdb
```

## 🔍 Troubleshooting

### InfluxDB Connection Issues
1. ตรวจสอบว่า InfluxDB container รันอยู่: `docker-compose ps`
2. ตรวจสอบ logs: `docker-compose logs influxdb`
3. รอให้ InfluxDB เริ่มต้นเสร็จ (อาจใช้เวลา 30-60 วินาที)

### Grafana Dashboard ไม่แสดงข้อมูล
1. ตรวจสอบ datasource connection ใน Grafana
2. ตรวจสอบว่า k6 ส่งข้อมูลไปยัง InfluxDB ถูกต้อง
3. ตรวจสอบ InfluxDB bucket และ organization

### K6 Test ไม่รัน
1. ตรวจสอบ target URL ว่า accessible หรือไม่
2. ตรวจสอบ TypeScript syntax error
3. ตรวจสอบ k6 container logs

## 📝 Advanced Configuration

### Environment Variables

สร้างไฟล์ `.env`:

```env
# InfluxDB Configuration
INFLUXDB_ADMIN_USER=admin
INFLUXDB_ADMIN_PASSWORD=adminpass
INFLUXDB_ORG=k6-org
INFLUXDB_BUCKET=k6
INFLUXDB_TOKEN=k6-token-1234567890

# Grafana Configuration
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=admin

# Target URL
TARGET_URL=http://your-app.com
```

### Custom Test Scripts

สร้าง test script ใหม่ในโฟลเดอร์ `k6/`:

```typescript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  // Your test configuration
};

export default function () {
  // Your test logic
}
```

## 🤝 Contributing

1. Fork the project
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## 📄 License

This project is licensed under the ISC License.

---

## 🆘 Quick Start

```bash
# 1. Start infrastructure
npm run start

# 2. Wait 30 seconds for services to start

# 3. Run your first test
npm run test:simple

# 4. Check results in Grafana
# Open http://localhost:3033 (admin/admin)
```

Happy Load Testing! 🚀
