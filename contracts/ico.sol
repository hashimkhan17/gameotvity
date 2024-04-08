// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./gameotivity.sol";

contract TokenSale {
    Gameotivity private tokenContract;
    address private admin;
    uint256 private tokenPrice;
    uint256 private tokensSold;
    uint256 private startDate;
    uint256 private endDate;

    uint256 public total_tokenholders;

    constructor(Gameotivity _tokenContract, uint256 _tokenPrice) {
        admin = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }


    function startICO(uint256 _startDate, uint256 _endDate) public {
        require(msg.sender == admin, "Only admin can start ICO");
        startDate = _startDate;
        endDate = _endDate;
    }

    
    function getStartDate() public view returns (uint256) {
        return startDate;
    }

    function getEndDate() public view returns (uint256) {
        return endDate;
    }

    // Internal function to perform safe multiplication
    function multiply(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "Multiplication overflow");
    }

    // Function to buy tokens during the ICO
    function buyToken(uint256 _numberOfTokens) public payable {
        require(block.timestamp >= startDate, "Sale has not started yet");
        require(block.timestamp <= endDate, "Sale has ended");
        require(msg.value == multiply(_numberOfTokens, tokenPrice), "Incorrect ethers amount sent");

        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens, "Not enough tokens in contract");

        require(tokenContract.transfer(msg.sender, _numberOfTokens), "Token transfer failed");

        tokensSold += _numberOfTokens;
    }

    // Function to end the token sale and transfer remaining tokens and ethers to admin
    function endSale() public {
        require(msg.sender == admin, "Only admin can end sale");

        require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))), "Token transfer to admin failed");

        payable(admin).transfer(address(this).balance);
    }
}
