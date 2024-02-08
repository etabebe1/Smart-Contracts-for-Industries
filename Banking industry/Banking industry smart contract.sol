// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Banking {
    // state variable
    mapping (address => uint256) balances;
    address payable owner;

    // constructor
    constructor() {
        owner = payable (msg.sender);
    }

    // function to deposit amount
    function deposit() public payable {
        require(msg.value > 0, "Depoist amount must be greater than 0.");
        balances[msg.sender] += msg.value;
    }

    // function to withdraw amount
    function withdraw(uint256 amount) public payable {
        require(msg.sender == owner, "Only the owner can withdraw!");
        require(amount <= balances[msg.sender], "Insufficent funds!");
        require(amount > 0, "Withdrawal amount must be greater than 0!");
        payable (msg.sender).transfer(amount);
        balances[msg.sender] -= amount;
    }

    // function to transfer funds 
    function transfer(address payable recipent, uint256 amount) public payable {
        require(amount <= balances[msg.sender], "Insufficent fund!");
        require(amount > 0, "Amount must be greater than 0!");
        balances[msg.sender] -= amount;
        balances[recipent] += amount;
    }

    // function to get balance
    function getBalance(address payable user) public view returns (uint256) {
        return balances[user];
    }

    // function to grant access
    function grantAccess(address payable user) public {
        require(msg.sender == owner, "Only the owner can grant access!");
        owner = user;
    }

    // function to revoke access
    function revokeAccess(address payable user) public {
        require(msg.sender == owner, "Only the owner can revoke the access!");
        require(user != owner, "Cannot revoke access for the current user!");
        owner = payable (msg.sender);
    }

    // function to destroy entire contract
    function destroy () public {
     require(msg.sender == owner, "Only the owner can destroy this contract!");

    // Transfer the contract balance to the owner
    selfdestruct(owner);

    }
}