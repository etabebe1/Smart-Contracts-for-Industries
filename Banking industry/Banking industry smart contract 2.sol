// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BankingContract {
    mapping(address => uint256) public balances;
    address payable owner;

    // events to be excuted in a differnet functions to emmit an events happening
    event Deposit(address indexed account, uint256 amount);
    event Withdrawal(address indexed account, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = payable (msg.sender);
    }

    // onlyOwner modifier --- is used to restrict ((transferOwnership)) function from excuted unless
    //                        a condition in the require is met.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
        
        // logging an event that contains two parameters
        // parameter - 1 - Contract owner
        //           - 2 - Ether value
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(amount <= balances[msg.sender], "Insufficient balance");
        
        // In the code bellow we're preventing re-entrancy attack 
        // BY - 1 decrementing senders amount 1st and then
        //    - 2 transfering the funds
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);

        // Finnaly logging Withdrawal event
        emit Withdrawal(msg.sender, amount);
    }

    function transfer(address to, uint256 amount) public {
        require(amount > 0, "Transfer amount must be greater than 0");
        require(amount <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        // checking if the newOwner account is valid 
        // in this case address(0) - is invalid addres
        require(newOwner != address(0), "Invalid new owner address");
        address previousOwner = owner;
        owner = payable (newOwner);
        emit OwnershipTransferred(previousOwner, newOwner);
    }
}
