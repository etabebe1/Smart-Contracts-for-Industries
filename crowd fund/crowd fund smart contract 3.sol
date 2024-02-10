// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// A Crowdfunding smart contract that allows users to contribute ether towards a funding goal within a set deadline.
contract Crowdfunding {
    // >> State Variabels << //
    // State variable to store the owner of the contract (the campaign creator).
    address public owner;
    // State variable to store the funding goal in wei.
    uint256 public goal;
    // State variable to store the deadline of the crowdfunding campaign.
    uint256 public deadline;
    // State variable to keep track of the total funds raised.
    uint256 public totalFundsRaised;
    // A mapping to keep track of how much each address has contributed.
    mapping(address => uint256) public contributions;
   
    // >> Event << //
    // Event emitted when a new contribution is made.
    event ContributionReceived(address contributor, uint256 amount);
    // Event emitted when the owner withdraws the funds after successful crowdfunding.
    event FundsWithdrawn(address owner, uint256 amount);
    // Event emitted if the crowdfunding campaign is successful.
    event CampaignSuccessful(uint256 totalFundsRaised);
    // Event emitted if the crowdfunding campaign fails (deadline passed without reaching the goal).
    event CampaignFailed();

    // >> modifier << //
    // Modifier to restrict certain functions to the contract's owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    // >> Constructor << //
    // Constructor to initialize the contract with a funding goal and a duration.
    constructor(uint256 _goal, uint256 _duration) {
        owner = msg.sender; // Set the contract creator as the owner.
        goal = _goal; // Set the funding goal.
        deadline = block.timestamp + _duration; // Set the deadline based on the current time and the duration.
    }

    // >> Functions << //
    // Function to contribute to the crowdfunding campaign.
    function contribute() public payable {
        require(block.timestamp < deadline, "The crowdfunding campaign has ended."); // Check if the deadline has not passed.
        require(msg.value > 0, "Contribution must be greater than 0."); // Check if the contribution is positive.

        contributions[msg.sender] += msg.value; // Update the contributor's contribution amount.
        totalFundsRaised += msg.value; // Update the total funds raised.

        emit ContributionReceived(msg.sender, msg.value); // Emit an event for the new contribution.
    }

    // Function to withdraw the funds if the goal is reached and the deadline has passed.
    function withdrawFunds() public onlyOwner {
        require(block.timestamp > deadline, "The crowdfunding campaign is still running."); // Ensure the deadline has passed.
        require(totalFundsRaised >= goal, "Funding goal has not been reached."); // Check if the goal is reached.

        payable(owner).transfer(address(this).balance); // Transfer all funds to the owner.
        emit FundsWithdrawn(owner, address(this).balance); // Emit an event for fund withdrawal.
    }

    // Function to check if the campaign was successful or failed after the deadline.
    function checkCampaignStatus() public {
        require(block.timestamp > deadline, "The crowdfunding campaign is still running."); // Ensure the deadline has passed.

        if (totalFundsRaised >= goal) {
            emit CampaignSuccessful(totalFundsRaised); // Emit an event if the campaign is successful.
        } else {
            emit CampaignFailed(); // Emit an event if the campaign failed.
        }
    }

    // Function to allow contributors to reclaim their funds if the campaign fails.
    function reclaimFunds() public {
        require(block.timestamp > deadline, "The crowdfunding campaign is still running."); // Ensure the deadline has passed.
        require(totalFundsRaised < goal, "Funding goal was reached, cannot reclaim funds."); // Check if the goal was not reached.

        uint256 contributedAmount = contributions[msg.sender]; // Get the amount contributed by the caller.
        require(contributedAmount > 0, "No funds to reclaim."); // Check if the caller has contributed.

        contributions[msg.sender] = 0; // Reset the caller's contribution to prevent re-entrancy.
        payable(msg.sender).transfer(contributedAmount); // Refund the contributed amount.
    }

    // Function to get the current balance of the contract.
    function getContractBalance() public view returns (uint256) {
        return address(this).balance; // Return the contract's balance.
    }
}
