// import http from 'k6/http';
// import { check, sleep } from 'k6';

// // export const options = {
// //   vus: 100,
// //   duration: '30s',
// //   thresholds: {
// //     http_req_duration: ['p(95)<200'],
// //     http_req_failed: ['rate<0.05'],
// //   },
// // };

// export const options = {
//     stages: [
//         { duration: '30s', target: 20 }, // Ramp-up to 20 VUs
//         { duration: '1m', target: 30 },  // Stay at 20 VUs for 1 minute
//         { duration: '10s', target: 0 },  // Ramp-down to 0 VUs
//     ],
// };


// export default function () {
//   const response = http.get('http://192.168.1.45:8088');
  
//   check(response, {
//     'status is 200': (r) => r.status === 200,
//     'response time < 200ms': (r) => r.timings.duration < 200,
//   });
  
//   sleep(0.5); //
// }

import http from 'k6/http';
import { check, sleep } from "k6";

const isNumeric = (value) => /^\d+$/.test(value);

const default_vus = 20;

const target_vus_env = `${__ENV.TARGET_VUS}`;
const target_vus = isNumeric(target_vus_env) ? Number(target_vus_env) : default_vus;

export let options = {
  stages: [
      // Ramp-up from 1 to TARGET_VUS virtual users (VUs) in 5s
      { duration: "5s", target: target_vus },

      // Stay at rest on TARGET_VUS VUs for 10s
      { duration: "10s", target: target_vus },

      // Ramp-down from TARGET_VUS to 0 VUs for 5s
      { duration: "5s", target: 0 }
  ]
};

export default function () {
  const response = http.get("http://192.168.1.45:8088", {headers: {Accepts: "application/json"}});
  check(response, { "status is 200": (r) => r.status === 200 });
  sleep(.300);
};