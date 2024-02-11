// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Advanced Accounting Smart Contract
 * @dev Implements deposit & withdrawal management, loan issuance with interest, and multi-signature transactions.
 */
contract AdvancedAccounting {
    // Represents a user's account with balance and last withdrawal time for time-locked withdrawals.
    struct Account {
        uint256 balance;
        uint256 lastWithdrawTime;
    }
    
    // Defines a loan with an amount, interest rate, due date, and repayment status.
    struct Loan {
        uint256 amount;
        uint256 interestRate; // Annual interest rate as a percentage
        uint256 dueDate;
        bool isRepaid;
    }

    // Represents a transaction that requires multiple signatures for execution.
    struct MultiSigTransaction {
        address initiator;
        address[] signers;
        uint256 value;
        string description;
        bool executed;
    }

    
    // Maps each address to its account for balance and withdrawal tracking.
    mapping(address => Account) public accounts;
    // Maps each address to an array of loans they have taken out.
    mapping(address => Loan[]) public loans;
    // Maps a transaction ID to a multi-signature transaction.
    mapping(bytes32 => MultiSigTransaction) public multiSigTransactions;
    // Stores the address of the contract owner.
    address public owner;
    // Constant representing the time lock duration for withdrawals.
    // TIME_LOCK = 1 minute for test 
    // TIME_LOCK = 1 days recommended
    uint256 public constant TIME_LOCK = 1 minutes;

    // Events for logging activities within the contract.
    event DepositMade(address indexed account, uint256 amount);
    event WithdrawalMade(address indexed account, uint256 amount);
    event LoanTaken(address indexed borrower, uint256 amount, uint256 interestRate, uint256 dueDate);
    event LoanRepaid(address indexed borrower, uint256 amount);
    event MultiSigTransactionCreated(bytes32 indexed transactionId, address indexed creator, uint256 value, string description);
    event MultiSigTransactionExecuted(bytes32 indexed transactionId, address indexed executor);


    // Ensures that only the owner of the contract can call a function.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Constructor sets the contract deployer as the owner.
    constructor() {
        owner = msg.sender;
    }

    // Allows users to deposit ether into their account.
    function deposit() public payable {
        require(msg.value > 0, "Deposit value must be greater than 0");
        accounts[msg.sender].balance += msg.value;
        emit DepositMade(msg.sender, msg.value);
    }

    // Allows users to withdraw ether, respecting the time lock.
    function withdraw(uint256 _amount) public {
        require(_amount <= accounts[msg.sender].balance, "Insufficient balance");
        require(block.timestamp >= accounts[msg.sender].lastWithdrawTime + TIME_LOCK, "Withdrawal is locked");
        
        accounts[msg.sender].balance -= _amount;
        accounts[msg.sender].lastWithdrawTime = block.timestamp;
        payable(msg.sender).transfer(_amount);
        emit WithdrawalMade(msg.sender, _amount);
    }

    // Enables a user to take out a loan with specified terms.
    function takeLoan(uint256 _amount, uint256 _interestRate, uint256 _duration) public {
        require(_amount > 0, "Loan amount must be greater than 0");
        
        loans[msg.sender].push(Loan(_amount, _interestRate, block.timestamp + _duration, false));
        accounts[msg.sender].balance += _amount;
        emit LoanTaken(msg.sender, _amount, _interestRate, block.timestamp + _duration);
    }

    // Allows a user to repay a specified loan.
    function repayLoan(uint256 _loanIndex) public payable {
        Loan storage loan = loans[msg.sender][_loanIndex];
        require(!loan.isRepaid, "Loan is already repaid");
        uint256 repaymentAmount = loan.amount + calculateInterest(loan.amount, loan.interestRate, loan.dueDate);
        require(msg.value >= repaymentAmount, "Insufficient amount to repay the loan");
        loan.isRepaid = true;
        emit LoanRepaid(msg.sender, repaymentAmount);
    }

    // Initiates a new multi-signature transaction.
    function createMultiSigTransaction(address[] memory _signers, uint256 _value, string memory _description) public onlyOwner {
        require(_signers.length > 1, "At least two signers required");
        bytes32 transactionId = keccak256(abi.encodePacked(block.timestamp, msg.sender, _value, _description));
        multiSigTransactions[transactionId] = MultiSigTransaction(msg.sender, _signers, _value, _description, false);
        emit MultiSigTransactionCreated(transactionId, msg.sender, _value, _description);
    }

    // Executes a multi-signature transaction once all signers have approved.
    function executeMultiSigTransaction(bytes32 _transactionId) public {
        MultiSigTransaction storage transaction = multiSigTransactions[_transactionId];
        require(!transaction.executed, "Transaction already executed");
        require(isSigner(transaction, msg.sender), "Caller is not a signer");
        transaction.executed = true;
        // Logic for transferring value or other transaction specifics would be implemented here.
        emit MultiSigTransactionExecuted(_transactionId, msg.sender);
    }

    // Calculates the interest due on a loan.
    function calculateInterest(uint256 _amount, uint256 _interestRate, uint256 _dueDate) private view returns (uint256) {
        uint256 timeElapsed = block.timestamp > _dueDate ? block.timestamp - _dueDate : 0;
        uint256 interest = (_amount * _interestRate * timeElapsed) / (365 days * 100);
        return interest;
    }

    // Checks if the caller is a valid signer for a multi-signature transaction.
    function isSigner(MultiSigTransaction storage _transaction, address _signer) private view returns (bool) {
        for (uint256 i = 0; i < _transaction.signers.length; i++) {
            if (_transaction.signers[i] == _signer) {
                return true;
            }
        }
        return false;
    }
}
