// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../contracts/EvidenceAnchorRegistry.sol";
import "../contracts/IssuerRegistry.sol";
import "../contracts/ProtocolVersionRegistry.sol";

/**
 * @title DeployAll
 * @dev Foundry deployment script for Base Sepolia testnet.
 */
contract DeployAll {
    function run(address deployerAdmin) external returns (
        address issuerRegistryAddr,
        address protocolRegistryAddr,
        address anchorRegistryAddr
    ) {
        IssuerRegistry issuerReg = new IssuerRegistry(deployerAdmin);
        ProtocolVersionRegistry protocolReg = new ProtocolVersionRegistry(deployerAdmin);
        EvidenceAnchorRegistry anchorReg = new EvidenceAnchorRegistry(
            deployerAdmin,
            address(issuerReg),
            address(protocolReg)
        );

        return (
            address(issuerReg),
            address(protocolReg),
            address(anchorReg)
        );
    }
}
