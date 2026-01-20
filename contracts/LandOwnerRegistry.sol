// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract LandOwnerRegistry is Ownable {
    struct LandOwner {
        address payoutWallet;
        string metadataURI;
        string cropType;
        uint256 cultivationCycleDays;
        bool approved;
    }

    uint256 private _ownerCount;
    mapping(uint256 => LandOwner) private _owners;

    event OwnerRegistered(
        uint256 indexed ownerId,
        address indexed payoutWallet,
        string metadataURI,
        string cropType,
        uint256 cultivationCycleDays
    );
    event OwnerApproved(uint256 indexed ownerId, address indexed approver);

    constructor(address initialOwner) Ownable(initialOwner) {}

    function registerOwner(
        address payoutWallet,
        string calldata metadataURI,
        string calldata cropType,
        uint256 cultivationCycleDays
    ) external returns (uint256 ownerId) {
        require(payoutWallet != address(0), "Invalid payout wallet");

        ownerId = ++_ownerCount;
        _owners[ownerId] = LandOwner({
            payoutWallet: payoutWallet,
            metadataURI: metadataURI,
            cropType: cropType,
            cultivationCycleDays: cultivationCycleDays,
            approved: false
        });

        emit OwnerRegistered(
            ownerId,
            payoutWallet,
            metadataURI,
            cropType,
            cultivationCycleDays
        );
    }

    function approveOwner(uint256 ownerId) external onlyOwner {
        LandOwner storage ownerData = _owners[ownerId];
        require(ownerData.payoutWallet != address(0), "Owner not found");
        require(!ownerData.approved, "Already approved");

        ownerData.approved = true;
        emit OwnerApproved(ownerId, msg.sender);
    }

    function getOwner(uint256 ownerId) external view returns (LandOwner memory) {
        return _owners[ownerId];
    }

    function ownerCount() external view returns (uint256) {
        return _ownerCount;
    }
}
