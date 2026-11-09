// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title EvidenceAttestationRegistry
 * @dev Nutrient Earth 2050 — Decentralized Scientific Evidence Attestation Anchor.
 * 
 * ARCHITECTURAL ISOLATION DIRECTIVE:
 * - This contract anchors ONLY cryptographic SHA-256 Merkle roots of peer-reviewed scientific evidence dossiers.
 * - ZERO Personally Identifiable Information (PII) or user health metrics are EVER written on-chain.
 * - Decoupled from the Nutrient Earth client application via an asynchronous Outbox Pattern.
 */
contract EvidenceAttestationRegistry {
    struct AttestationBatch {
        bytes32 merkleRoot;
        uint256 batchSize;
        uint256 anchoredAt;
        string manifestUri; // IPFS or verified decentralized archive CID
    }

    address public owner;
    bool public paused;
    uint256 public totalBatches;

    mapping(uint256 => AttestationBatch) public batches;
    mapping(bytes32 => bool) public knownRoots;

    event AttestationAnchored(
        uint256 indexed batchId,
        bytes32 indexed merkleRoot,
        uint256 batchSize,
        uint256 timestamp,
        string manifestUri
    );

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Paused(address account);
    event Unpaused(address account);

    modifier onlyOwner() {
        require(msg.sender == owner, "EvidenceAttestationRegistry: caller is not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "EvidenceAttestationRegistry: contract is paused");
        _;
    }

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Anchors a new cryptographic Merkle root representing a batch of verified evidence digests.
     */
    function anchorEvidenceBatch(
        bytes32 _merkleRoot,
        uint256 _batchSize,
        string calldata _manifestUri
    ) external onlyOwner whenNotPaused returns (uint256 batchId) {
        require(_merkleRoot != bytes32(0), "EvidenceAttestationRegistry: invalid zero root");
        require(_batchSize > 0, "EvidenceAttestationRegistry: batch size must be positive");
        require(!knownRoots[_merkleRoot], "EvidenceAttestationRegistry: root already anchored");

        batchId = totalBatches;
        batches[batchId] = AttestationBatch({
            merkleRoot: _merkleRoot,
            batchSize: _batchSize,
            anchoredAt: block.timestamp,
            manifestUri: _manifestUri
        });

        knownRoots[_merkleRoot] = true;
        totalBatches++;

        emit AttestationAnchored(batchId, _merkleRoot, _batchSize, block.timestamp, _manifestUri);
    }

    /**
     * @dev Verifies whether a specific scientific claim hash belongs to an anchored Merkle root.
     */
    function verifyLeaf(
        bytes32 leafHash,
        bytes32[] calldata proof,
        bytes32 root
    ) external pure returns (bool) {
        require(root != bytes32(0), "EvidenceAttestationRegistry: root is zero");
        bytes32 computedHash = leafHash;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
        if (_paused) {
            emit Paused(msg.sender);
        } else {
            emit Unpaused(msg.sender);
        }
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "EvidenceAttestationRegistry: zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

