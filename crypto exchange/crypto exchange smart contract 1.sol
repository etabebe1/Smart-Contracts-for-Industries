// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// EXCHANGE

contract Exchange {
    // state variables
    address public owner;
    mapping (address => mapping(address =>uint256)) public balances;
    mapping (address => bool) public authorizedToken;
    uint256 public fee = 0.1 ether; // taking 0.1 ether commision per exchange

    // events
    event deposit(address  indexed token, address indexed user, uint256 amount);
    event withdraw(address indexed token, address indexed user, uint256 amount);
    event trade(address indexed token, address indexed buyer, address indexed seller, uint256 price);

    // consturctor
    constructor () {
        owner = msg.sender;
    }

    // restirctive modifier
    modifier onlyOwner () {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // functions
    function Deposit(address token, uint256 amount) public {
        require(authorizedToken[token], "Token is not aouthorized.");
        require(amount > 0, "Amount must be > 0.");

        balances[token][msg.sender] += amount;
        emit deposit(token, msg.sender, amount);
    }

    function Withdraw(address token, uint256 amount) public {
        require(balances[token][msg.sender] > amount, "Insuffiecent balance.");

        balances[token][msg.sender] -= amount;
        emit withdraw(token, msg.sender, amount);
    }

    function authorizeToken(address token) public onlyOwner {
        authorizedToken[token] = true;
    }

    function revokeToken(address token) public onlyOwner {
        authorizedToken[token] = false;
    }
    
    function setFee(uint256 newFee) public {
        fee = newFee;
    } 

    function Trade(address token, address seller, uint256 amount, uint256 price) public payable  {
        require(msg.value == fee, "Insufficent fund.");
        require(balances[token][seller] > amount, "Insufficent balance");
        require(balances[address(this)][msg.sender] >= amount * price, "Insufficent balance");

        balances[token][seller] -= amount;
        balances[token][msg.sender] += amount;
        balances[address(this)][msg.sender] -= amount * price;
        balances[address(this)][seller] += amount * price;
    
        emit trade(token, msg.sender, seller, price);
    }
}