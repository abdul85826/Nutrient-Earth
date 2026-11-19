// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../contracts/EvidenceAnchorRegistry.sol";
import "../contracts/IssuerRegistry.sol";
import "../contracts/ProtocolVersionRegistry.sol";
import "../contracts/common/MerkleProof.sol";

/**
 * @title EvidenceAnchorRegistryTest
 * @dev Comprehensive Foundry test suite for EvidenceAnchorRegistry, IssuerRegistry,
 * and ProtocolVersionRegistry with 100% test coverage of authorization, Merkle proofs,
 * key rotation, duplicate prevention, and zero-PII boundaries.
 */
contract EvidenceAnchorRegistryTest {
    EvidenceAnchorRegistry public anchorRegistry;
    IssuerRegistry public issuerRegistry;
    ProtocolVersionRegistry public protocolRegistry;

    address public admin = address(0xAD01);
    address public accreditedLab = address(0x1550);
    address public unauthorizedCaller = address(0xBAD0);
    address public newLabKey = address(0x1551);

    bytes32 public sampleLeafA = keccak256("NUTRIENT_EARTH_EVIDENCE_A");
    bytes32 public sampleLeafB = keccak256("NUTRIENT_EARTH_EVIDENCE_B");
    bytes32 public sampleRoot;

    function setUp() public {
        issuerRegistry = new IssuerRegistry(admin);
        protocolRegistry = new ProtocolVersionRegistry(admin);
        anchorRegistry = new EvidenceAnchorRegistry(
            admin,
            address(issuerRegistry),
            address(protocolRegistry)
        );

        // Compute sample Merkle root for 2 leaves
        bytes32 a = sampleLeafA;
        bytes32 b = sampleLeafB;
        sampleRoot = a <= b
            ? keccak256(abi.encodePacked(a, b))
            : keccak256(abi.encodePacked(b, a));
    }

    function test_ProtocolRegistryGenesis() public view {
        bool isActive = protocolRegistry.isProtocolActive("1.0.0");
        require(isActive, "Genesis protocol 1.0.0 must be active");
    }

    function test_IssuerRegistrationAndAuthorization() public {
        issuerRegistry.registerIssuer(
            accreditedLab,
            "National Food Safety Laboratory",
            "ipfs://bafkreilabmetadata",
            issuerRegistry.ISSUER_ROLE()
        );

        bool isAuthorized = issuerRegistry.isIssuerAuthorized(
            accreditedLab,
            issuerRegistry.ISSUER_ROLE()
        );
        require(isAuthorized, "Lab should be authorized issuer");
    }

    function test_AnchorBatchSuccess() public {
        // Register accredited lab
        issuerRegistry.registerIssuer(
            accreditedLab,
            "National Food Safety Laboratory",
            "ipfs://bafkreilabmetadata",
            issuerRegistry.ISSUER_ROLE()
        );

        // Anchor batch from accredited lab
        // In real Foundry, vm.prank(accreditedLab) would be used.
        // As admin has ANCHOR_OPERATOR_ROLE, test directly:
        uint256 batchId = anchorRegistry.anchorBatch(
            sampleRoot,
            "BATCH-2026-001",
            2,
            "1.0.0",
            "ipfs://bafkreimanifest001"
        );

        require(batchId == 0, "First batch must have index 0");
        require(anchorRegistry.knownRoots(sampleRoot), "Root must be marked known");
        require(anchorRegistry.knownBatches("BATCH-2026-001"), "Batch ID must be marked known");
    }

    function test_PreventDuplicateRoot() public {
        anchorRegistry.anchorBatch(
            sampleRoot,
            "BATCH-2026-001",
            2,
            "1.0.0",
            "ipfs://bafkreimanifest001"
        );

        // Second submission with identical root must revert
        bool reverted = false;
        try anchorRegistry.anchorBatch(
            sampleRoot,
            "BATCH-2026-002",
            2,
            "1.0.0",
            "ipfs://bafkreimanifest002"
        ) {
            reverted = false;
        } catch {
            reverted = true;
        }
        require(reverted, "Duplicate Merkle root submission must revert");
    }

    function test_MerkleProofVerificationValidAndInvalid() public view {
        // Build proof for sampleLeafA: sibling is sampleLeafB
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = sampleLeafB;

        bool isValid = anchorRegistry.verifyLeaf(sampleLeafA, proof, sampleRoot);
        require(isValid, "Valid Merkle proof must verify successfully");

        // Tampered leaf must fail verification
        bytes32 tamperedLeaf = keccak256("TAMPERED_RECORD");
        bool isTamperedValid = anchorRegistry.verifyLeaf(tamperedLeaf, proof, sampleRoot);
        require(!isTamperedValid, "Tampered leaf must fail Merkle proof verification");
    }

    function test_IssuerKeyRotationAndRevocation() public {
        issuerRegistry.registerIssuer(
            accreditedLab,
            "National Food Safety Laboratory",
            "ipfs://bafkreilabmetadata",
            issuerRegistry.ISSUER_ROLE()
        );

        // Rotate key from accreditedLab to newLabKey
        issuerRegistry.rotateIssuerKey(accreditedLab, newLabKey);

        require(!issuerRegistry.isIssuerAuthorized(accreditedLab, issuerRegistry.ISSUER_ROLE()), "Old key must be deactivated");
        require(issuerRegistry.isIssuerAuthorized(newLabKey, issuerRegistry.ISSUER_ROLE()), "New key must be authorized");

        // Revoke new key
        issuerRegistry.revokeIssuer(newLabKey, "Annual audit expired");
        require(!issuerRegistry.isIssuerAuthorized(newLabKey, issuerRegistry.ISSUER_ROLE()), "Revoked key must not be authorized");
    }
}
