// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./common/AccessControl.sol";
import "./common/Pausable.sol";

/**
 * @title ProtocolVersionRegistry
 * @dev Manages canonical protocol versions, schema definitions, and hashing standards.
 * Ensures historical verification remains intact across upgrades.
 */
contract ProtocolVersionRegistry is AccessControl, Pausable {
    bytes32 public constant PROTOCOL_ADMIN_ROLE = keccak256("PROTOCOL_ADMIN_ROLE");

    struct ProtocolInfo {
        string version; // e.g. "1.0.0"
        string schemaUri; // Canonical JSON schema URI
        string hashingStandard; // e.g. "KECCAK256_RFC8785"
        bool isActive;
        bool isDeprecated;
        uint256 registeredAt;
        uint256 deprecatedAt;
    }

    mapping(string => ProtocolInfo) private _protocols;
    string[] private _allVersions;

    event ProtocolVersionRegistered(string version, string schemaUri, string hashingStandard, uint256 timestamp);
    event ProtocolVersionDeprecated(string version, uint256 timestamp);

    error ProtocolAlreadyRegistered(string version);
    error ProtocolNotRegistered(string version);
    error ProtocolAlreadyDeprecated(string version);

    constructor(address initialAdmin) {
        _grantRole(DEFAULT_ADMIN_ROLE, initialAdmin);
        _grantRole(PROTOCOL_ADMIN_ROLE, initialAdmin);

        // Register genesis protocol v1.0.0
        _registerProtocol("1.0.0", "ipfs://bafkreinutrientearthschema100", "KECCAK256_RFC8785");
    }

    function registerProtocolVersion(
        string calldata version,
        string calldata schemaUri,
        string calldata hashingStandard
    ) external onlyRole(PROTOCOL_ADMIN_ROLE) whenNotPaused {
        _registerProtocol(version, schemaUri, hashingStandard);
    }

    function deprecateProtocolVersion(string calldata version) external onlyRole(PROTOCOL_ADMIN_ROLE) {
        ProtocolInfo storage info = _protocols[version];
        if (info.registeredAt == 0) revert ProtocolNotRegistered(version);
        if (info.isDeprecated) revert ProtocolAlreadyDeprecated(version);

        info.isActive = false;
        info.isDeprecated = true;
        info.deprecatedAt = block.timestamp;

        emit ProtocolVersionDeprecated(version, block.timestamp);
    }

    function isProtocolActive(string calldata version) external view returns (bool) {
        return _protocols[version].isActive;
    }

    function isProtocolValidHistorical(string calldata version) external view returns (bool) {
        return _protocols[version].registeredAt != 0;
    }

    function getProtocol(string calldata version) external view returns (ProtocolInfo memory) {
        return _protocols[version];
    }

    function _registerProtocol(
        string memory version,
        string memory schemaUri,
        string memory hashingStandard
    ) internal {
        if (_protocols[version].registeredAt != 0) revert ProtocolAlreadyRegistered(version);

        _protocols[version] = ProtocolInfo({
            version: version,
            schemaUri: schemaUri,
            hashingStandard: hashingStandard,
            isActive: true,
            isDeprecated: false,
            registeredAt: block.timestamp,
            deprecatedAt: 0
        });

        _allVersions.push(version);
        emit ProtocolVersionRegistered(version, schemaUri, hashingStandard, block.timestamp);
    }
}
