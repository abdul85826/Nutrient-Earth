# Nutrient Earth — Scalability & Load Testing Plan

**Document Version:** 1.0.0  
**Auditor:** Performance Engineer & Reliability Architect  
**Date:** 2026-10-26  
**Tooling:** k6 / Grafana k6 Cloud / Locust  

---

## 1. Load Testing Objectives & Safety Guardrails

The objective of this load testing strategy is to empirically model real-world user journeys on the Nutrient Earth backend, identify infrastructure bottlenecks, establish database connection pool limits, and verify system recovery without destabilizing production environments.

### Inviolable Safety Rules
1. **Never load test against production endpoints without explicit written approval.**
2. **Execute tests exclusively against isolated staging/local Supabase instances (`http://localhost:54321` or dedicated staging cluster).**
3. **Emergency Stop Thresholds:** Abort tests immediately if:
   - Error rate exceeds **2.0%**.
   - p95 latency exceeds **2,500ms**.
   - Database CPU utilization exceeds **85%**.

---

## 2. Realistic User Journey Scenarios

| Scenario | Weight | Description | Simulated Actions |
| :--- | :--- | :--- | :--- |
| **A. Diurnal Routine & Check-In** | 50% | User opens app, reads diurnal greeting, syncs telemetry, toggles 1-2 checklist tasks. | 1 GET telemetry, 1 GET profile, 1-2 PATCH task completion. |
| **B. Scientific Literature Inquiry** | 30% | User searches nutritional question (e.g., magnesium bioavailability). | 1 POST inquiry endpoint, RAG retrieval, 1 GET citations. |
| **C. Learn Content Browsing** | 15% | User browses media grid, opens article or video detail modal. | 1 GET learn content, 1 GET media details. |
| **D. Health Lab Document Upload** | 5% | User uploads 2MB-5MB PDF blood panel or nutrition label photo. | 1 POST `/storage/v1/object/health-reports`, 1 INSERT metadata. |

---

## 3. Graduated Load Testing Stages

| Stage | Target Virtual Users (VUs) | Duration | Ramp-Up | Success Criteria |
| :--- | :--- | :--- | :--- | :--- |
| **Stage 1: Smoke Test** | 10 VUs | 2 min | 30s | 100% success, p95 < 200ms |
| **Stage 2: Normal Peak** | 100 VUs | 5 min | 1 min | Error rate < 0.1%, p95 < 400ms |
| **Stage 3: Stressed Load**| 500 VUs | 10 min | 2 min | Error rate < 0.5%, p95 < 800ms |
| **Stage 4: Surge Traffic** | 1,000 VUs | 10 min | 3 min | Error rate < 1.0%, p95 < 1,200ms |
| **Stage 5: High Concurrency**| 5,000 VUs | 15 min | 5 min | Error rate < 2.0%, p95 < 2,000ms |
| **Stage 6: Stress Ceiling** | 10,000 VUs | 10 min | 5 min | Measure breaking point & auto-recovery |

---

## 4. Key Performance Indicators (KPIs) & Targets

| Metric | Target | Warning Threshold | Critical Failure Threshold |
| :--- | :--- | :--- | :--- |
| **Successful Request Rate** | > 99.5% | < 99.0% | < 98.0% |
| **p50 Latency (Median)** | < 150 ms | > 300 ms | > 500 ms |
| **p95 Latency** | < 450 ms | > 800 ms | > 1,500 ms |
| **p99 Latency** | < 900 ms | > 1,500 ms | > 2,500 ms |
| **Database Pool Utilization**| < 70% | > 80% | > 95% (Exhaustion) |
| **AI Synthesis Latency** | < 1,800 ms | > 3,000 ms | > 5,000 ms |

---

## 5. k6 Script Reference Implementation (`load_test_scenarios.js`)

```javascript
import http from 'k6/http';
import { check, sleep, group } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 50 },
    { duration: '3m', target: 200 },
    { duration: '1m', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<800'],
    http_req_failed: ['rate<0.01'],
  },
};

const BASE_URL = __ENV.TARGET_URL || 'http://localhost:54321';
const HEADERS = {
  'Content-Type': 'application/json',
  'apikey': __ENV.SUPABASE_ANON_KEY || 'mock-key',
};

export default function () {
  group('Diurnal & Telemetry Sync', function () {
    const res = http.get(`${BASE_URL}/rest/v1/learn_content?select=id,title,category`, { headers: HEADERS });
    check(res, {
      'status is 200': (r) => r.status === 200,
      'response time < 400ms': (r) => r.timings.duration < 400,
    });
  });

  sleep(1);
}
```
