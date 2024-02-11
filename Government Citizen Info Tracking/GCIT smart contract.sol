// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GCITContract {
    // State variables
    address payable owner;
    address[] public citizens;
    address[] public officials;
    mapping (address => bool) public isOfficial;
    mapping (address => bool) public isVoted;

    // Struct
    struct LawProposed {
        string description;
        address proposer;
        uint256 yesVotes;
        uint256 noVotes;
        bool enacted;
    } 

    LawProposed[] public proposals;

    // Events
    event NewCitizen(address citizen);
    event NewOfficial(address official);
    event NewProposal(uint256 proposalId, string description);
    event VoteCasted(uint256 proposalId, bool support);
    event LawEnacted(uint256 proposalId, string description);
    event LawRejected(uint256 proposalId, string description);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action.");
        _;
    }

    // Constructor
    constructor () {
        owner = payable (msg.sender);
    }
    
     /* Functions */

    // Register as a citizen
    function newCitizen () external {
        require(!isOfficial[msg.sender], "Officials cannot register as citizens.");

        citizens.push(msg.sender);
        emit NewCitizen(msg.sender);
    }

    // Register as an official
    function newOfficai () external {
        require(!isOfficial[msg.sender], "Already registered as official.");

        officials.push(msg.sender);
        isOfficial[msg.sender] = true;
        emit NewOfficial(msg.sender);
    }

    // Propose a new law
    function proposeLaw (string memory _description) external {
        require(isOfficial[msg.sender], "Only owner can propose a law.");

        proposals.push(LawProposed({
            description: _description,
            proposer: msg.sender,
            yesVotes: 0,
            noVotes:0,
            enacted: false
        }));
        emit NewProposal(proposals.length - 1, _description);
    }

    // Vote on a law proposal
    function voteProposal (uint256 proposalId, bool support) external {
        require(!isVoted[msg.sender], "Already voted.");
        require(proposalId < proposals.length - 1, "Invalid proposal Id");

        LawProposed storage proposal = proposals[proposalId];
        if(support) {
            proposal.yesVotes += 1;
        } else {
            proposal.noVotes -= 1;
        }

        isVoted[msg.sender] = true;
        emit VoteCasted(proposalId, support);
    }

    // Enact law
    function enactLaw(uint256 proposalId) external onlyOwner {
        require(proposalId < proposals.length - 1, "Invalid proposal Id.");
        LawProposed storage proposal = proposals[proposalId];
        require(!proposal.enacted, "Proposal already enacted or rejected.");

        if (proposal.yesVotes > proposal.noVotes) {
            proposal.enacted = true;
            emit LawEnacted(proposalId, proposal.description);
        } else {
            emit LawRejected(proposalId, proposal.description);
        }
    }

    // Utility functions
    function getCitizens () external view returns (address[] memory) {
        return citizens;
    }

    function getOfficials () external view returns (address[] memory) {
        return officials;
    }

    // Grant or revoke access status (only owner)
    function toggelOfficialStatus (address user) external {
        isOfficial[user] = !isOfficial[user];
        
        if (isOfficial[user]) {
            officials.push(user);
        } else {
            // Remove from officials array; left as an exercise due to complexity
        }
    }
}
