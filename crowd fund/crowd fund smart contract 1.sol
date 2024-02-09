// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// Crowd funding smart contract

contract Crowdfunding {
    // State Variables
    address public owner;
    uint256 public goalSet;
    uint256 public deadline;
    uint256 public totalContributions;
    mapping (address => uint256) contributions;
    bool public isFunded;
    bool public isCompleted;

    // Events 
    event GoalReached (uint256 totalContributions);
    event FundTransfered (address backer, uint256 amount);
    event DeadlineReached (uint256 totalContributions);

    // constuctor - here we'll be defining logics that happen by the tiem of deployment
    constructor (uint256 fundingGoalInEther, uint256 durationInMinute) {
        owner = msg.sender;
        goalSet = fundingGoalInEther * 1 ether;
        deadline = block.timestamp + durationInMinute * 1 minutes;
        isFunded = false;
        isCompleted = false;
    } 

    // modifier to restrict certain actions
    modifier onlyOwner () {
        require(msg.sender == owner, "Only the owner can perform this action!");
        _;
    }

    // the function bellow has no restictions
    // it can be called buy anyone who want to contribute
    function contribute () public payable  {
        require(block.timestamp < deadline, "Funding has already reached the deadline");
        require(!isCompleted, "Crowd funding is already completed");

        uint256 contribution = msg.value;
        contributions[msg.sender] += contribution;
        totalContributions += contribution;

        if (totalContributions >= goalSet) {
            isCompleted = true;
            emit GoalReached(totalContributions);
        }

        emit FundTransfered(msg.sender, contribution);
    }


    // the function bellow is allowed only by the creator || owner of this contract
    // once the crowed funding is completed the owner of the contract can withdraw contributions
    function withdraw () public {
        require(isFunded, "Goal has not been reached");
        require(!isCompleted, "Crowdfunding has already completed");

        isCompleted = true;
        payable(owner).transfer(address(this).balance);
    } 

    // the function bellow is allowed to get refund that the caller of this function has already contribiuted
    function getRefund() public {
        require(block.timestamp >= deadline, "Funding period has not ended.");
        require(!isFunded, "Goal has been reached");
        require(contributions[msg.sender] > 0, "No contribution to refund");

        // the logic bellow prevents rentrancy attack by updating the balance first then make a transaction.
        uint256 contribution = contributions[msg.sender];
        contributions[msg.sender] = 0;
        totalContributions -= contribution;
        payable (msg.sender).transfer(contribution);
        emit FundTransfered(msg.sender, contribution);
    }

    // the function bellow can be called by anyone who want to get current balance
    function getCurrentBalance() public view returns(uint256) {
        return address(this).balance;
    }

    // the functions bellow is to extend dealine 
    function extendDeadline(uint256 durationInMinute) public onlyOwner {
        deadline += durationInMinute * 1 minutes;
    } 

    // the functions bellow is to decrease deadline
    function decreaseDeadline(uint256 durationInMinute) public onlyOwner {
        uint256 newDeadline = deadline - (durationInMinute * 1 minutes);
        require(block.timestamp + 5 minutes <=  newDeadline);
        deadline -= durationInMinute * 1 minutes;
    } 

}
