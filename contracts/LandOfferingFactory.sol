// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {LandOwnerRegistry} from "./LandOwnerRegistry.sol";
import {LandShareToken} from "./LandShareToken.sol";
import {LandOffering} from "./LandOffering.sol";
import {ProfitDistributor} from "./ProfitDistributor.sol";

contract LandOfferingFactory is Ownable {
    struct Offering {
        uint256 ownerId;
        address ownerWallet;
        address token;
        address offering;
        address distributor;
        string metadataURI;
        uint256 pricePerShare;
        uint256 totalShares;
    }

    LandOwnerRegistry public immutable ownerRegistry;
    address public immutable usdc;

    Offering[] private _offerings;

    event OfferingCreated(
        uint256 indexed offeringId,
        uint256 indexed ownerId,
        address token,
        address offering,
        address distributor,
        uint256 pricePerShare,
        uint256 totalShares
    );

    constructor(address ownerRegistryAddress, address usdcAddress, address initialOwner)
        Ownable(initialOwner)
    {
        require(ownerRegistryAddress != address(0), "Registry required");
        require(usdcAddress != address(0), "USDC required");

        ownerRegistry = LandOwnerRegistry(ownerRegistryAddress);
        usdc = usdcAddress;
    }

    function createOffering(
        uint256 ownerId,
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        uint256 totalShares,
        uint256 pricePerShare
    ) external onlyOwner returns (uint256 offeringId) {
        LandOwnerRegistry.LandOwner memory ownerData = ownerRegistry.getOwner(ownerId);
        require(ownerData.payoutWallet != address(0), "Owner missing");
        require(ownerData.approved, "Owner not approved");

        LandShareToken token = new LandShareToken(name, symbol, address(this));
        LandOffering offering = new LandOffering(
            usdc,
            address(token),
            ownerData.payoutWallet,
            pricePerShare,
            totalShares
        );
        ProfitDistributor distributor = new ProfitDistributor(usdc, address(token));

        token.transferOwnership(address(offering));

        Offering memory record = Offering({
            ownerId: ownerId,
            ownerWallet: ownerData.payoutWallet,
            token: address(token),
            offering: address(offering),
            distributor: address(distributor),
            metadataURI: metadataURI,
            pricePerShare: pricePerShare,
            totalShares: totalShares
        });

        _offerings.push(record);
        offeringId = _offerings.length - 1;

        emit OfferingCreated(
            offeringId,
            ownerId,
            address(token),
            address(offering),
            address(distributor),
            pricePerShare,
            totalShares
        );
    }

    function offeringsCount() external view returns (uint256) {
        return _offerings.length;
    }

    function getOffering(uint256 offeringId) external view returns (Offering memory) {
        return _offerings[offeringId];
    }
}
