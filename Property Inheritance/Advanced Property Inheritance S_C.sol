// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdvancedInheritance {
    address public owner;
    bool public paused = false;
    mapping(address => Executor) public executors;
    mapping(address => Beneficiary) public beneficiaries;

    struct Executor {
        bool isExecutor;
        uint256 lastActionTimestamp;
    }

    struct Beneficiary {
        uint256 inheritance;
        bool isBeneficiary;
        uint256 claimAfter;
    }

    event InheritanceReceived(address indexed from, uint256 amount);
    event BeneficiaryAdded(address indexed beneficiary, uint256 claimAfter);
    event BeneficiaryRemoved(address indexed beneficiary);
    event InheritanceClaimed(address indexed beneficiary, uint256 amount);
    event ContractPaused();
    event ContractUnpaused();

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier onlyExecutors() {
        require(executors[msg.sender].isExecutor, "Only designated executors can perform this action.");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is currently paused.");
        _;
    }

    constructor() {
        owner = msg.sender;
        // Initialize the owner as an executor by default
        executors[msg.sender] = Executor({isExecutor: true, lastActionTimestamp: block.timestamp});
    }

    function pauseContract() external onlyOwner {
        paused = true;
        emit ContractPaused();
    }

    function unpauseContract() external onlyOwner {
        paused = false;
        emit ContractUnpaused();
    }

    function addExecutor(address _executor) external onlyOwner {
        executors[_executor] = Executor({isExecutor: true, lastActionTimestamp: block.timestamp});
    }

    function removeExecutor(address _executor) external onlyOwner {
        executors[_executor].isExecutor = false;
    }

    function addBeneficiary(address _beneficiary, uint256 _claimAfter) external onlyExecutors whenNotPaused {
        require(_beneficiary != address(0), "Beneficiary address is invalid.");
        beneficiaries[_beneficiary] = Beneficiary({inheritance: 0, isBeneficiary: true, claimAfter: _claimAfter});
        emit BeneficiaryAdded(_beneficiary, _claimAfter);
    }

    function removeBeneficiary(address _beneficiary) external onlyExecutors whenNotPaused {
        require(_beneficiary != address(0), "Beneficiary address is invalid.");
        beneficiaries[_beneficiary].isBeneficiary = false;
        emit BeneficiaryRemoved(_beneficiary);
    }

    function distributeInheritance(address _beneficiary, uint256 _amount) external onlyExecutors whenNotPaused {
        require(beneficiaries[_beneficiary].isBeneficiary, "Provided address is not a beneficiary.");
        require(_amount > 0, "Amount must be greater than 0.");
        require(block.timestamp >= beneficiaries[_beneficiary].claimAfter, "Beneficiary cannot claim before the set date.");
        
        beneficiaries[_beneficiary].inheritance += _amount;
    }

    function claimInheritance() external whenNotPaused {
        require(beneficiaries[msg.sender].isBeneficiary, "Caller is not a beneficiary.");
        require(block.timestamp >= beneficiaries[msg.sender].claimAfter, "Cannot claim inheritance yet.");

        uint256 amount = beneficiaries[msg.sender].inheritance;
        require(amount > 0, "No inheritance to claim.");

        beneficiaries[msg.sender].inheritance = 0; // Reset inheritance to prevent re-claiming
        payable(msg.sender).transfer(amount);

        emit InheritanceClaimed(msg.sender, amount);
    }

    receive() external payable {
        require(msg.value > 0, "Cannot receive zero ether.");
    }

    function addFunds() external payable onlyOwner whenNotPaused {
        // Funds added to contract can be distributed to beneficiaries
    }
