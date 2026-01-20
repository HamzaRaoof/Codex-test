// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {LandShareToken} from "./LandShareToken.sol";

contract ProfitDistributor {
    using SafeERC20 for IERC20;

    uint256 public constant REWARD_SCALE = 1e18;

    IERC20 public immutable usdc;
    LandShareToken public immutable shareToken;

    uint256 public rewardPerShareStored;
    mapping(address => uint256) public userRewardPerSharePaid;

    event PayoutFunded(address indexed funder, uint256 amount, uint256 rewardPerShare);
    event RewardClaimed(address indexed account, uint256 amount);

    constructor(address usdcAddress, address shareTokenAddress) {
        require(usdcAddress != address(0), "USDC required");
        require(shareTokenAddress != address(0), "Token required");

        usdc = IERC20(usdcAddress);
        shareToken = LandShareToken(shareTokenAddress);
    }

    function fundPayout(uint256 amount) external {
        require(amount > 0, "Amount required");

        uint256 totalSupply = shareToken.totalSupply();
        require(totalSupply > 0, "No shares");

        usdc.safeTransferFrom(msg.sender, address(this), amount);
        rewardPerShareStored += (amount * REWARD_SCALE) / totalSupply;

        emit PayoutFunded(msg.sender, amount, rewardPerShareStored);
    }

    function claim() external {
        uint256 reward = _earned(msg.sender);
        require(reward > 0, "No reward");

        userRewardPerSharePaid[msg.sender] = rewardPerShareStored;
        usdc.safeTransfer(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward);
    }

    function earned(address account) external view returns (uint256) {
        return _earned(account);
    }

    function _earned(address account) internal view returns (uint256) {
        uint256 balance = shareToken.balanceOf(account);
        uint256 paid = userRewardPerSharePaid[account];
        uint256 rewardPerShareDelta = rewardPerShareStored - paid;

        return (balance * rewardPerShareDelta) / REWARD_SCALE;
    }
}
