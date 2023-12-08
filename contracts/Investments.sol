// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Investments is Ownable {
    uint256 public constant MAX_INVESTMENT = 4.5 ether;
    uint256 public totalInvested;

    struct Investor {
        uint256 amount;
        bool exists;
    }

    mapping(address => Investor) public investors;
    address[] private investorAddresses;

    constructor() {
        totalInvested = 0;
    }

    function deposit() public payable {
        require(totalInvested + msg.value <= MAX_INVESTMENT, "Investment limit exceeded");
        if (!investors[msg.sender].exists) {
            investorAddresses.push(msg.sender);
            investors[msg.sender].exists = true;
        }
        investors[msg.sender].amount += msg.value;
        totalInvested += msg.value;
    }

    function getInvestors() public view returns (address[] memory, uint256[] memory) {
        uint256[] memory amounts = new uint256[](investorAddresses.length);
        for (uint256 i = 0; i < investorAddresses.length; i++) {
            amounts[i] = investors[investorAddresses[i]].amount;
        }
        return (investorAddresses, amounts);
    }
    
    function getTotalInvested() public view returns (uint256) {
        return totalInvested;
    }

    function withdraw(uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner()).transfer(amount);
    }

    function withdrawTokens(IERC20 token) public onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        token.transfer(owner(), balance);
    }

    // Fallback function to accept ETH directly sent to the contract
    receive() external payable {
        deposit();
    }
}
