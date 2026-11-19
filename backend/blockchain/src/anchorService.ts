// ==============================================================================
// Nutrient Earth — Typed Smart Contract Interaction Service
// ==============================================================================

import { getPublicClient } from './client.js';
import { Hex, MerkleBatchSubmission, VerificationRequest, VerificationVerdict } from './types.js';

export const EvidenceAnchorRegistryABI = [
  {
    name: 'anchorBatch',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'merkleRoot', type: 'bytes32' },
      { name: 'batchId', type: 'string' },
      { name: 'batchSize', type: 'uint256' },
      { name: 'protocolVersion', type: 'string' },
      { name: 'manifestUri', type: 'string' },
    ],
    outputs: [{ name: 'batchIndex', type: 'uint256' }],
  },
  {
    name: 'verifyLeaf',
    type: 'function',
    stateMutability: 'pure',
    inputs: [
      { name: 'leafHash', type: 'bytes32' },
      { name: 'proof', type: 'bytes32[]' },
      { name: 'root', type: 'bytes32' },
    ],
    outputs: [{ name: '', type: 'bool' }],
  },
  {
    name: 'knownRoots',
    type: 'function',
    stateMutability: 'view',
    inputs: [{ name: '', type: 'bytes32' }],
    outputs: [{ name: '', type: 'bool' }],
  },
  {
    name: 'totalBatches',
    type: 'function',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'uint256' }],
  },
] as const;

export class BlockchainVerificationBackendService {
  private contractAddress: Hex;
  private chainId: number;

  constructor(contractAddress: Hex, chainId: number = 84532) {
    this.contractAddress = contractAddress;
    this.chainId = chainId;
  }

  async verifyLeafOnChain(req: VerificationRequest): Promise<VerificationVerdict> {
    const client = getPublicClient(this.chainId);

    try {
      // 1. Check if root is known
      const isKnown = await client.readContract({
        address: this.contractAddress,
        abi: EvidenceAnchorRegistryABI,
        functionName: 'knownRoots',
        args: [req.root],
      });

      if (!isKnown) {
        return 'UNKNOWN_BATCH';
      }

      // 2. Call on-chain pure verifyLeaf
      const isValid = await client.readContract({
        address: this.contractAddress,
        abi: EvidenceAnchorRegistryABI,
        functionName: 'verifyLeaf',
        args: [req.leafHash, req.proof, req.root],
      });

      return isValid ? 'VALID_COMMITMENT' : 'INVALID_COMMITMENT';
    } catch (e) {
      return 'INSUFFICIENT_VERIFICATION_DATA';
    }
  }
}
