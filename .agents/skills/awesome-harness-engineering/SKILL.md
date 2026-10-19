---
name: awesome-harness-engineering
description: >-
  Agent benchmarking, evaluation harnesses, sandboxed execution, and regression testing.
  Use when designing eval suites, scoring LLM outputs, testing tool calling accuracy,
  and building continuous agent verification testbeds.
metadata:
  author: ant-agent
  version: "1.0.0"
---

# Awesome Harness Engineering & Agent Evals

This skill provides methodologies for building deterministic test harnesses, benchmarking agentic decision loops, and scoring multi-step tool interactions.

---

## 1. Agent Evaluation Dimensions

Evaluate autonomous coding agents across 4 core axes:
1. **Pass Rate**: Did the agent produce code that satisfies static analysis and unit tests (`flutter test`, `npm test`)?
2. **Tool Efficiency**: Number of tool calls, avoided hallucinated tools, zero redundant calls.
3. **Safety Compliance**: Did the agent respect boundary rules (e.g., zero hardcoded credentials, confirmation on destructive commands)?
4. **Context Hygiene**: Proper usage of compaction, bounded scratch files, low token footprint.

---

## 2. Test Harness Structure

```typescript
export interface TestCase {
  id: string;
  task: string;
  expectedFiles: string[];
  verificationCommand: string;
  timeoutMs: number;
}

export async function runHarness(testCases: TestCase[]) {
  const results = [];

  for (const test of testCases) {
    const startTime = Date.now();
    try {
      // 1. Setup isolated sandbox workspace
      // 2. Invoke agent with test.task
      // 3. Execute test.verificationCommand
      // 4. Record output, duration, and exit code
      results.push({ id: test.id, passed: true, duration: Date.now() - startTime });
    } catch (error) {
      results.push({ id: test.id, passed: false, error: String(error) });
    }
  }

  return results;
}
```

---

## 3. Regression Prevention Rules
- Never declare a feature or fix done based on assumptions; run empirical static analysis and tests first.
- If a regression occurs, write a reproduction test case into the harness suite before implementing the fix.
