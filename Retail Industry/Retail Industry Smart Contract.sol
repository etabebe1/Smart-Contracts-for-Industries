// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Retail industry

contract Retail {
    
    struct Product {
        bytes32 name;
        uint256 price;
        uint256 stock;
    } 

    mapping (bytes32 => Product) public products;
    address payable owner;

    constructor() {
        owner = payable (msg.sender);
    }

    modifier onlyOwner () {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function addProduct (bytes32 name, uint256 price, uint256 stock) external onlyOwner {
        products[name] = Product(name, price, stock);
    }

    function updateProductPrice (bytes32 name, uint256 price) external onlyOwner {
        require(products[name].price > price, "Product does not exist.");

        products[name].price = price;
    }

    function updateProductStock (bytes32 name, uint256 stock) external onlyOwner {
        require(products[name].stock > stock, "Product does not exist.");

        products[name].stock = stock;
    }

    function purchase(bytes32 name, uint256 quantitiy) external payable {
        require(msg.value >= products[name].price * quantitiy, "Insufficent funds.");
        require(quantitiy <= products[name].stock, "Not enough stock.");

        products[name].stock -= quantitiy;
    }

    function getProduct (bytes32 name) external view returns (bytes32, uint256, uint256) {
        return (products[name].name, products[name].price, products[name].stock);
    }

    function grantAccess (address payable user) external onlyOwner {
        owner = user;
    }

    function revokeAccess (address payable user) external onlyOwner {
        require(user != owner, "Cannot revoke access for the current owner.");

        owner = payable (msg.sender);
    }

    function destroyContract () external onlyOwner {
        selfdestruct(owner);
    }

}