// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./common/AccessControl.sol";
import "./common/Pausable.sol";

/**
 * @title IssuerRegistry
 * @dev Manages accredited institutions, laboratories, and operational signing keys.
 * Supports role-based access, key rotation, and immediate revocation for compromised keys.
 */
contract IssuerRegistry is AccessControl, Pausable {
    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    struct IssuerInfo {
        address issuerAddress;
        string organizationName;
        string metadataUri;
        bytes32 assignedRole;
        bool isActive;
        uint256 registeredAt;
        uint256 revokedAt;
        string revocationReason;
    }

    mapping(address => IssuerInfo) private _issuers;
    address[] private _allIssuers;

    event IssuerRegistered(address indexed issuerAddress, string organizationName, bytes32 role, uint256 timestamp);
    event IssuerKeyRotated(address indexed oldKey, address indexed newKey, uint256 timestamp);
    event IssuerRevoked(address indexed issuerAddress, string reason, uint256 timestamp);

    error InvalidAddress();
    error IssuerAlreadyRegistered(address issuerAddress);
    error IssuerNotRegistered(address issuerAddress);
    error IssuerAlreadyRevoked(address issuerAddress);

    constructor(address initialAdmin) {
        if (initialAdmin == address(0)) revert InvalidAddress();
        _grantRole(DEFAULT_ADMIN_ROLE, initialAdmin);
        _grantRole(OPERATOR_ROLE, initialAdmin);
    }

    /**
     * @dev Registers an accredited testing laboratory or research institution.
     */
    function registerIssuer(
        address issuerAddress,
        string calldata organizationName,
        string calldata metadataUri,
        bytes32 role
    ) external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        if (issuerAddress == address(0)) revert InvalidAddress();
        if (_issuers[issuerAddress].registeredAt != 0) revert IssuerAlreadyRegistered(issuerAddress);

        _issuers[issuerAddress] = IssuerInfo({
            issuerAddress: issuerAddress,
            organizationName: organizationName,
            metadataUri: metadataUri,
            assignedRole: role,
            isActive: true,
            registeredAt: block.timestamp,
            revokedAt: 0,
            revocationReason: ""
        });

        _allIssuers.push(issuerAddress);
        _grantRole(role, issuerAddress);

        emit IssuerRegistered(issuerAddress, organizationName, role, block.timestamp);
    }

    /**
     * @dev Rotates an active issuer's key to a new operational address without invalidating historical records.
     */
    function rotateIssuerKey(address oldKey, address newKey) external whenNotPaused {
        if (newKey == address(0)) revert InvalidAddress();
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender) && msg.sender != oldKey) {
            revert AccessControlUnauthorizedAccount(msg.sender, DEFAULT_ADMIN_ROLE);
        }

        IssuerInfo storage current = _issuers[oldKey];
        if (current.registeredAt == 0) revert IssuerNotRegistered(oldKey);
        if (!current.isActive) revert IssuerAlreadyRevoked(oldKey);
        if (_issuers[newKey].registeredAt != 0) revert IssuerAlreadyRegistered(newKey);

        bytes32 role = current.assignedRole;

        // Deactivate old key
        current.isActive = false;
        current.revokedAt = block.timestamp;
        current.revocationReason = "Key rotated to new operational address";
        _revokeRole(role, oldKey);

        // Register new key with migrated attributes
        _issuers[newKey] = IssuerInfo({
            issuerAddress: newKey,
            organizationName: current.organizationName,
            metadataUri: current.metadataUri,
            assignedRole: role,
            isActive: true,
            registeredAt: block.timestamp,
            revokedAt: 0,
            revocationReason: ""
        });

        _allIssuers.push(newKey);
        _grantRole(role, newKey);

        emit IssuerKeyRotated(oldKey, newKey, block.timestamp);
    }

    /**
     * @dev Revokes an issuer key permanently (e.g. key compromise or loss of accreditation).
     */
    function revokeIssuer(address issuerAddress, string calldata reason) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IssuerInfo storage current = _issuers[issuerAddress];
        if (current.registeredAt == 0) revert IssuerNotRegistered(issuerAddress);
        if (!current.isActive) revert IssuerAlreadyRevoked(issuerAddress);

        current.isActive = false;
        current.revokedAt = block.timestamp;
        current.revocationReason = reason;

        _revokeRole(current.assignedRole, issuerAddress);

        emit IssuerRevoked(issuerAddress, reason, block.timestamp);
    }

    /**
     * @dev Returns true if an issuer is registered, active, and possesses the queried role.
     */
    function isIssuerAuthorized(address issuerAddress, bytes32 role) external view returns (bool) {
        return _issuers[issuerAddress].isActive && hasRole(role, issuerAddress);
    }

    function getIssuer(address issuerAddress) external view returns (IssuerInfo memory) {
        return _issuers[issuerAddress];
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}
