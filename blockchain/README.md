# Nutrient Earth — Blockchain Architecture & Isolation Boundary

## 1. Architectural Mandate
All blockchain, Web3, attestation, smart contract, and Merkle proof components in Nutrient Earth are quarantined inside this `blockchain/` root folder.

### Strict Isolation Rules:
1. **Zero Runtime Dependency**: The Nutrient Earth Flutter application (Android, iOS, Web) does NOT depend on the availability of any blockchain network or RPC node. If the blockchain network is unreachable, paused, or partitioned, Nutrient Earth functions with 100% feature availability and 0ms latency impact.
2. **Zero PII on Chain**: No user profiles, biometrics, meals, health conditions, or private identifiers are EVER transmitted to smart contracts or on-chain storage.
3. **Outbox Pattern**: Attestation tasks are enqueued asynchronously in the background (`BlockchainOutboxWorker`). The main user thread never blocks on web3 transaction confirmation.
4. **Decentralized Scientific Evidence Only**: The only data anchored on-chain are cryptographic SHA-256 Merkle roots representing batches of peer-reviewed clinical research and food composition database citations.

## 2. Directory Structure
```
blockchain/
  ├── contracts/
  │   └── EvidenceAttestationRegistry.sol   # Solidity smart contract for Merkle root anchoring
  ├── adapters/
  │   └── web3_notarization_adapter.dart    # Abstract Web3 adapter with mock & RPC drivers
  ├── services/
  │   ├── merkle_proof_service.dart         # SHA-256 deterministic Merkle tree & proof generator
  │   └── outbox_worker.dart                # Asynchronous outbox worker with retry & dead-letter queue
  └── tests/
      └── blockchain_isolation_test.dart    # Test suite verifying offline resilience & zero PII
```

## 3. Verification & Testing
To execute the isolation tests, run:
```bash
flutter test test/blockchain_isolation_test.dart
```

