// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// A contract for basic accounting operations, including tracking transactions, deposits, and withdrawals.
contract Accounting {
    // A struct to represent the details of a transaction.
    struct Transaction {
        address sender; // The address sending the funds.
        address receiver; // The address receiving the funds.
        uint256 amount; // The amount of funds transferred.
        uint256 timestamp; // The timestamp when the transaction occurred.
        string description; // A text description of the transaction.
    }
    
    // Mapping to track the balance of each address.
    mapping (address => uint256) public balances;
    // An array to store all transactions.
    Transaction[] public transactions;
    // The owner of the contract.
    address public owner;

    // Events to log actions on the blockchain.
    event deposit(address indexed account, uint256 amount);
    event withdaraw(address indexed account, uint256 amount);
    event transactionAdded(
        uint256 indexed id,
        address indexed sender, 
        address indexed receiver, 
        uint256 amount, 
        uint256 timestamp, 
        string description
    );

    // The constructor sets the initial owner of the contract to the address that deploys it.
    constructor() {
        owner = msg.sender;
    }

    // A modifier to restrict certain functions to be callable only by the owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function!");
        _; // Continue execution of the function.
    }  

    // Function to deposit funds into the contract and credit the sender's balance.
    function Deposit() public payable {
        require(msg.value > 0, "Insufficient funds");
        
        balances[msg.sender] += msg.value;
        emit deposit(msg.sender, msg.value);
    }

    // Function to withdraw funds from the contract if the sender has enough balance.
    function Withdraw(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero.");
        require(balances[msg.sender] >= amount, "Insufficient funds.");
        
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit withdaraw(msg.sender, amount);
    }

    // Function to record a transaction and update balances accordingly.
    function addTransaction(address receiver, uint256 amount, string memory description) public {
        require(amount > 0, "Amount must be greater than 0.");
        require(receiver != address(0), "Provided address is a zero address");

        balances[msg.sender] -= amount;
        balances[receiver] += amount;

        transactions.push(Transaction(msg.sender, receiver, amount, block.timestamp, description));
        emit transactionAdded(transactions.length - 1, msg.sender, receiver, amount, block.timestamp, description);
    }

    // Function to get the total number of transactions recorded.
    function getTransactionsCount() public view returns (uint256) {
        return transactions.length;
    }

    // Function to retrieve details of a specific transaction by its ID.
    function getTransactionById(uint256 ID) public view returns (
        uint256, 
        address, 
        address, 
        uint256, 
        string memory
    ) {
        require(ID < transactions.length, "Invalid transaction id.");

        Transaction memory transaction = transactions[ID];
        return (
            transaction.amount, 
            transaction.sender, 
            transaction.receiver,
            transaction.timestamp,
            transaction.description
        );
    }
}
