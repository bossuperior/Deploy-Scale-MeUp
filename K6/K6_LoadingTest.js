import http from 'k6/http';
import { check } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://scalemeup-node-alb-609231817.ap-southeast-1.elb.amazonaws.com';
const PATH = __ENV.PATH || '/api/posts';
const URL = `${BASE_URL}${PATH}`;

export const options = {
    discardResponseBodies: true,
    scenarios: {
        autoscale_like: {
            executor: 'ramping-arrival-rate',
            timeUnit: '1s',
            startRate: 20,             // เริ่มที่ 20 RPS (เพิ่ม RPS ตอนเริ่มต้น)
            preAllocatedVUs: 100,
            maxVUs: 100,               // ห้ามเกิน 100 users
            stages: [
                { duration: '2m', target: 60 },   // warm-up เพิ่มการโหลด
                { duration: '3m', target: 120 },  // ดันโหลดเพิ่มขึ้นไปอีก
                { duration: '2m', target: 150 },  // ramp ขึ้นถึง 150
                { duration: '8m', target: 150 },  // hold ให้โหลดอยู่ที่ 150 เพื่อทดสอบ scale-out
                { duration: '3m', target: 60 },   // ลดลงเป็น 60 RPS
                { duration: '4m', target: 20 },   // ลดลงไปที่ 20 RPS (ทดสอบการลดสเกล)
            ],
            gracefulStop: '30s',
        },
    },
    thresholds: {
        http_req_failed:   ['rate<0.02'],
        http_req_duration: ['p(95)<2000'],
    },
};

export default function () {
    // กัน cache/CDN ด้วย query สดทุกครั้ง
    const u = URL + (URL.includes('?') ? '&' : '?') + 'nocache=' + Date.now();

    const res = http.get(u, {
        timeout: '30s',
        tags: { name: `GET ${PATH}` },
    });

    check(res, { 'status 2xx/3xx': r => r.status >= 200 && r.status < 400 });
}