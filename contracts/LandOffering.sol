// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {LandShareToken} from "./LandShareToken.sol";

contract LandOffering {
    using SafeERC20 for IERC20;

    IERC20 public immutable usdc;
    LandShareToken public immutable shareToken;
    address public immutable payoutWallet;
    uint256 public immutable pricePerShare;
    uint256 public immutable totalShares;

    uint256 public sharesSold;

    event SharesPurchased(address indexed buyer, uint256 amount, uint256 cost);

    constructor(
        address usdcAddress,
        address shareTokenAddress,
        address payoutWalletAddress,
        uint256 pricePerShareAmount,
        uint256 totalSharesAmount
    ) {
        require(usdcAddress != address(0), "USDC required");
        require(shareTokenAddress != address(0), "Token required");
        require(payoutWalletAddress != address(0), "Payout wallet required");
        require(pricePerShareAmount > 0, "Price required");
        require(totalSharesAmount > 0, "Total shares required");

        usdc = IERC20(usdcAddress);
        shareToken = LandShareToken(shareTokenAddress);
        payoutWallet = payoutWalletAddress;
        pricePerShare = pricePerShareAmount;
        totalShares = totalSharesAmount;
    }

    function buyShares(uint256 amount) external {
        require(amount > 0, "Amount required");
        require(sharesSold + amount <= totalShares, "Not enough shares");

        uint256 cost = amount * pricePerShare;
        sharesSold += amount;

        usdc.safeTransferFrom(msg.sender, payoutWallet, cost);
        shareToken.mint(msg.sender, amount);

        emit SharesPurchased(msg.sender, amount, cost);
    }
}
