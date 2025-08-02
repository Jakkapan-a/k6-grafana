import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '5m', target: 100 }, // Ramp up to 100 users
    { duration: '10m', target: 100 }, // Stay at 100 users for 10 minutes
    { duration: '5m', target: 0 }, // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(99)<1500'], // 99% of requests must complete below 1.5s
    http_req_failed: ['rate<0.02'], // Error rate must be less than 2%
  },
};

export default function () {
  const baseUrl = 'http://127.0.0.1:8088';
  
  // Simulate user behavior
  let response = http.get(baseUrl);
  check(response, {
    'homepage status is 200': (r) => r.status === 200,
  });
  
  sleep(Math.random() * 3 + 2); // Random sleep between 2-5 seconds
  
  // Test API endpoint
  response = http.get(`${baseUrl}/api/health`);
  check(response, {
    'health check status is 200': (r) => r.status === 200,
  });
  
  sleep(Math.random() * 2 + 1); // Random sleep between 1-3 seconds
}
