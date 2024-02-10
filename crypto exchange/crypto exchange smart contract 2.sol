// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


// TokenExchange
// A simple exchange contract for trading IERC-20 tokens

contract TokenExchange {
    // State variables
    address public owner; // Owner of the contract

    // Events
    event TokenPurchase(address indexed buyer, address indexed token, uint256 amount, uint256 price);
    event TokenSale(address indexed seller, address indexed token, uint256 amount, uint256 price);

    // Sets the contract deployer as the owner
     
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Allows users to buy tokens for Ether at a specified price.
     * @param token Address of the IERC-20 token to buy
     * @param tokenAmount Amount of tokens to buy
     * @param tokenPrice Price per token in Ether
     */
    function buyToken(address token, uint256 tokenAmount, uint256 tokenPrice) external payable {
        uint256 etherAmount = tokenAmount * tokenPrice;
        require(msg.value >= etherAmount, "Not enough Ether sent");

        IERC20(token).transfer(msg.sender, tokenAmount);

        emit TokenPurchase(msg.sender, token, tokenAmount, tokenPrice);
    }

    /**
     * @dev Allows users to sell tokens for Ether at a specified price.
     * @param token Address of the IERC-20 token to sell
     * @param tokenAmount Amount of tokens to sell
     * @param tokenPrice Price per token in Ether
     */
    function sellToken(address token, uint256 tokenAmount, uint256 tokenPrice) external {
        uint256 etherAmount = tokenAmount * tokenPrice;
        require(address(this).balance >= etherAmount, "Contract does not have enough Ether");

        IERC20(token).transferFrom(msg.sender, address(this), tokenAmount);
        payable(msg.sender).transfer(etherAmount);

        emit TokenSale(msg.sender, token, tokenAmount, tokenPrice);
    }

    /**
     * @dev Allows the owner to withdraw Ether from the contract.
     */
    function withdrawEther() external {
        require(msg.sender == owner, "Only the owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

    /**
     * @dev Returns the Ether balance of the contract.
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
