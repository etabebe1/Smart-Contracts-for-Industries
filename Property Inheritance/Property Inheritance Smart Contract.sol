// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Property Inheritance Smart Contract

contract Inheritance {
    address public owner;
    mapping (address => uint256) public inheritances;
    mapping (address => bool) public areBeneficiaries;

    event InheritanceReceived(address indexed from, uint256 amount);
    event BeneficiaryAdded(address indexed beneficiary);
    event BeneficiaryRemoved(address indexed beneficiary);
    event InheritanceDistributed(address indexed beneficiary, uint256 amount);

    constructor () {
        owner = msg.sender;
    }

    modifier onlyOwner () {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function receivedInheritance() external payable {
        require(msg.value > 0, "Amount must be greater than 0.");

        inheritances[msg.sender] += msg.value;
        emit InheritanceReceived(msg.sender, msg.value);
    }

    function addBeneficiary (address beneficiary) external  {
        require(beneficiary != address(0), "Beneficiary address is invalid address.");

        areBeneficiaries[beneficiary] = true;
        emit BeneficiaryAdded(beneficiary); 
    }

    function removeBeneficiary (address beneficiary) external {
        require(beneficiary != address(0), "Beneficiary address is invalid address");
        require(areBeneficiaries[beneficiary], "Provided address is not beneficiary.");

        areBeneficiaries[beneficiary] = false;
        emit BeneficiaryRemoved(beneficiary);
    }

    function distributeBeneficiary (address beneficiary, uint256 amount) external onlyOwner {
        require(beneficiary != address(0), "Beneficiary address is invalid address.");
        require(areBeneficiaries[beneficiary], "Provided address is not beneficiary");
        require(amount > 0, "amount has to be greater than 0.");
        require(amount <= inheritances[owner], "Insufficent funds");
        
        inheritances[owner] -= amount;
        inheritances[beneficiary] += amount;

        emit InheritanceDistributed(beneficiary, amount);
    }
}


// Similar but more readable && clean using struct
contract Inheritance2 {
    address public owner;
    mapping(address => Beneficiary) public beneficiaries;

    struct Beneficiary {
        uint256 inheritance;
        bool isBeneficiary;
    }

    event InheritanceReceived(address indexed from, uint256 amount);
    event BeneficiaryAdded(address indexed beneficiary);
    event BeneficiaryRemoved(address indexed beneficiary);
    event InheritanceDistributed(address indexed beneficiary, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function receivedInheritance() external payable {
        require(msg.value > 0, "Amount must be greater than 0.");
        Beneficiary storage beneficiary = beneficiaries[msg.sender];
        beneficiary.inheritance += msg.value;
        beneficiary.isBeneficiary = true; // Optionally set true here if you want all who send funds to be marked as beneficiaries

        emit InheritanceReceived(msg.sender, msg.value);
    }

    function addBeneficiary(address _beneficiary) external onlyOwner {
        require(_beneficiary != address(0), "Beneficiary address is invalid.");
        beneficiaries[_beneficiary].isBeneficiary = true;
        
        emit BeneficiaryAdded(_beneficiary);
    }

    function removeBeneficiary(address _beneficiary) external onlyOwner {
        require(_beneficiary != address(0), "Beneficiary address is invalid.");
        require(beneficiaries[_beneficiary].isBeneficiary, "Provided address is not a beneficiary.");
        
        beneficiaries[_beneficiary].isBeneficiary = false;
        
        emit BeneficiaryRemoved(_beneficiary);
    }

    function distributeBeneficiary(address _beneficiary, uint256 _amount) external onlyOwner {
        require(_beneficiary != address(0), "Beneficiary address is invalid.");
        require(beneficiaries[_beneficiary].isBeneficiary, "Provided address is not a beneficiary.");
        require(_amount > 0 && _amount <= beneficiaries[owner].inheritance, "Insufficient funds.");
        
        beneficiaries[owner].inheritance -= _amount;
        beneficiaries[_beneficiary].inheritance += _amount;

        emit InheritanceDistributed(_beneficiary, _amount);
    }
}
