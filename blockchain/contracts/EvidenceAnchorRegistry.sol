// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./common/AccessControl.sol";
import "./common/Pausable.sol";
import "./common/ReentrancyGuard.sol";
import "./common/MerkleProof.sol";
import "./IssuerRegistry.sol";
import "./ProtocolVersionRegistry.sol";

/**
 * @title EvidenceAnchorRegistry
 * @dev Nutrient Earth — Decentralized Cryptographic Evidence Anchor.
 * Anchors Merkle roots of peer-reviewed clinical dossiers and product assessments.
 * Strict zero-PII boundary: Only stores bytes32 Merkle roots and non-sensitive batch IDs.
 */
contract EvidenceAnchorRegistry is AccessControl, Pausable, ReentrancyGuard {
    bytes32 public constant ANCHOR_OPERATOR_ROLE = keccak256("ANCHOR_OPERATOR_ROLE");

    struct BatchRecord {
        bytes32 merkleRoot;
        string batchId;
        uint256 batchSize;
        string protocolVersion;
        string manifestUri;
        address anchoredBy;
        uint256 blockTimestamp;
        uint256 blockNumber;
    }

    IssuerRegistry public immutable issuerRegistry;
    ProtocolVersionRegistry public immutable protocolRegistry;

    uint256 public totalBatches;
    mapping(uint256 => BatchRecord) private _batches;
    mapping(bytes32 => bool) public knownRoots;
    mapping(string => bool) public knownBatches;

    event BatchAnchored(
        uint256 indexed batchIndex,
        string indexed batchId,
        bytes32 indexed merkleRoot,
        uint256 batchSize,
        string protocolVersion,
        string manifestUri,
        address anchoredBy,
        uint256 timestamp
    );

    error InvalidRoot();
    error InvalidBatchSize();
    error EmptyBatchId();
    error RootAlreadyAnchored(bytes32 root);
    error BatchIdAlreadyAnchored(string batchId);
    error UnauthorizedAnchorOperator(address caller);
    error InactiveProtocolVersion(string protocolVersion);
    error BatchNotFound(uint256 batchIndex);

    constructor(
        address initialAdmin,
        address _issuerRegistry,
        address _protocolRegistry
    ) {
        if (initialAdmin == address(0) || _issuerRegistry == address(0) || _protocolRegistry == address(0)) {
            revert AccessControlUnauthorizedAccount(address(0), DEFAULT_ADMIN_ROLE);
        }

        issuerRegistry = IssuerRegistry(_issuerRegistry);
        protocolRegistry = ProtocolVersionRegistry(_protocolRegistry);

        _grantRole(DEFAULT_ADMIN_ROLE, initialAdmin);
        _grantRole(ANCHOR_OPERATOR_ROLE, initialAdmin);
    }

    /**
     * @dev Anchors a Merkle root representing a verified batch of scientific evidence or product assessments.
     */
    function anchorBatch(
        bytes32 merkleRoot,
        string calldata batchId,
        uint256 batchSize,
        string calldata protocolVersion,
        string calldata manifestUri
    ) external nonReentrant whenNotPaused returns (uint256 batchIndex) {
        if (merkleRoot == bytes32(0)) revert InvalidRoot();
        if (batchSize == 0) revert InvalidBatchSize();
        if (bytes(batchId).length == 0) revert EmptyBatchId();
        if (knownRoots[merkleRoot]) revert RootAlreadyAnchored(merkleRoot);
        if (knownBatches[batchId]) revert BatchIdAlreadyAnchored(batchId);

        // 1. Check protocol version is active
        if (!protocolRegistry.isProtocolActive(protocolVersion)) {
            revert InactiveProtocolVersion(protocolVersion);
        }

        // 2. Check authorization: caller must have ANCHOR_OPERATOR_ROLE or be an authorized issuer
        bool isOperator = hasRole(ANCHOR_OPERATOR_ROLE, msg.sender);
        bool isAuthorizedIssuer = issuerRegistry.isIssuerAuthorized(msg.sender, issuerRegistry.ISSUER_ROLE());

        if (!isOperator && !isAuthorizedIssuer) {
            revert UnauthorizedAnchorOperator(msg.sender);
        }

        batchIndex = totalBatches;
        _batches[batchIndex] = BatchRecord({
            merkleRoot: merkleRoot,
            batchId: batchId,
            batchSize: batchSize,
            protocolVersion: protocolVersion,
            manifestUri: manifestUri,
            anchoredBy: msg.sender,
            blockTimestamp: block.timestamp,
            blockNumber: block.number
        });

        knownRoots[merkleRoot] = true;
        knownBatches[batchId] = true;
        totalBatches++;

        emit BatchAnchored(
            batchIndex,
            batchId,
            merkleRoot,
            batchSize,
            protocolVersion,
            manifestUri,
            msg.sender,
            block.timestamp
        );
    }

    /**
     * @dev Verifies a cryptographic leaf against an anchored Merkle root using standard EVM sorted-pair proof.
     */
    function verifyLeaf(
        bytes32 leafHash,
        bytes32[] calldata proof,
        bytes32 root
    ) external pure returns (bool) {
        if (root == bytes32(0) || leafHash == bytes32(0)) return false;
        return MerkleProof.verify(proof, root, leafHash);
    }

    function getBatch(uint256 batchIndex) external view returns (BatchRecord memory) {
        if (batchIndex >= totalBatches) revert BatchNotFound(batchIndex);
        return _batches[batchIndex];
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}
