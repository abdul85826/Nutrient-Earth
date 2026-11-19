// ==============================================================================
// Nutrient Earth — Typed Blockchain Contracts & Payloads
// ==============================================================================

export type Hex = `0x${string}`;

export interface MerkleBatchSubmission {
  merkleRoot: Hex;
  batchId: string;
  batchSize: bigint;
  protocolVersion: string;
  manifestUri: string;
}

export interface BatchRecordOnChain {
  merkleRoot: Hex;
  batchId: string;
  batchSize: bigint;
  protocolVersion: string;
  manifestUri: string;
  anchoredBy: Hex;
  blockTimestamp: bigint;
  blockNumber: bigint;
}

export interface VerificationRequest {
  leafHash: Hex;
  proof: Hex[];
  root: Hex;
  batchId: string;
  protocolVersion: string;
  issuerAddress?: Hex;
}

export type VerificationVerdict =
  | 'VALID_COMMITMENT'
  | 'INVALID_COMMITMENT'
  | 'UNKNOWN_BATCH'
  | 'UNCONFIRMED_TRANSACTION'
  | 'REVOKED_ISSUER'
  | 'UNSUPPORTED_PROTOCOL'
  | 'INSUFFICIENT_VERIFICATION_DATA';
