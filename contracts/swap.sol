// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenSwap {
    using SafeERC20 for IERC20;

    address public owner;
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public exchangeRate;

    event Swap(address indexed user, uint256 amountA, uint256 amountB);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(
        address _tokenA,
        address _tokenB,
        uint256 _exchangeRate
    ) {
        owner = msg.sender;
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        exchangeRate = _exchangeRate;
    }

    function swapAForB(uint256 amountA) external {
        uint256 amountB = (amountA * exchangeRate) / 1e18; // Calculate amountB based on exchange rate
        require(tokenA.balanceOf(msg.sender) >= amountA, "Insufficient balance of TokenA");
        require(tokenB.balanceOf(address(this)) >= amountB, "Insufficient balance of TokenB");

        tokenA.safeTransferFrom(msg.sender, address(this), amountA);
        tokenB.safeTransfer(msg.sender, amountB);

        emit Swap(msg.sender, amountA, amountB);
    }

    function swapBForA(uint256 amountB) external {
        uint256 amountA = (amountB * 1e18) / exchangeRate; // Calculate amountA based on exchange rate
        require(tokenB.balanceOf(msg.sender) >= amountB, "Insufficient balance of TokenB");
        require(tokenA.balanceOf(address(this)) >= amountA, "Insufficient balance of TokenA");

        tokenB.safeTransferFrom(msg.sender, address(this), amountB);
        tokenA.safeTransfer(msg.sender, amountA);

        emit Swap(msg.sender, amountB, amountA);
    }

    // Owner functions to update parameters
    function setExchangeRate(uint256 _exchangeRate) external onlyOwner {
        exchangeRate = _exchangeRate;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }
}
