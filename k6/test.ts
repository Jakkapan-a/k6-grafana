import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

// กำหนด Custom Metrics
const errorRate = new Rate('errors');
const responseTime = new Trend('response_time');
const requests = new Counter('requests');

export const options = {
  stages: [
    { duration: '30s', target: 10 }, // Ramp up
    { duration: '1m', target: 50 }, // Stay at 50 VUs
    { duration: '30s', target: 100 }, // Ramp up to 100 VUs
    { duration: '1m', target: 100 }, // Stay at 100 VUs
    { duration: '30s', target: 0 }, // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% ของ requests ต้องเสร็จภายใน 500ms
    http_req_failed: ['rate<0.1'], // Error rate ต้องน้อยกว่า 10%
    errors: ['rate<0.1'], // Custom error rate
  },
};

export default function () {
  // Test data - สามารถแก้ไข URL ตามต้องการ
  const baseUrl = 'http://127.0.0.1:8088';
  
  // Test different endpoints
  const endpoints = [
    '/',
    '/api/health',
    '/api/users',
  ];
  
  const endpoint = endpoints[Math.floor(Math.random() * endpoints.length)];
  const url = baseUrl + endpoint;
  
  const params = {
    headers: {
      'User-Agent': 'k6-load-test',
      'Content-Type': 'application/json',
    },
    timeout: '30s',
  };

  const response = http.get(url, params);
  
  // Record metrics
  requests.add(1);
  responseTime.add(response.timings.duration);
  
  // Checks
  const isSuccess = check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
    'response has content': (r) => r.body && (typeof r.body === 'string' ? r.body.length > 0 : r.body.byteLength > 0),
  });
  
  errorRate.add(!isSuccess);
  
  // Random sleep between 1-3 seconds
  sleep(Math.random() * 2 + 1);
}
