// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Interface for the ERC20 token standard.
interface IERC20 {
    // Function to transfer tokens to a specified address.
    function transfer(address, uint) external returns (bool);

    // Function to allow a spender to withdraw from your account, multiple times, up to the amount.
    function transferFrom(address, address, uint) external returns (bool);
}

// Main contract for creating and managing crowdfunding campaigns.
contract CrowdFund {
    // Events for logging actions on the blockchain.
    event Launch(uint id, address indexed creator, uint goal, uint32 startAt, uint32 endAt);
    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint id, address indexed caller, uint amount);

    // Struct to hold campaign data.
    struct Campaign {
        address creator; // The account that created the campaign.
        uint goal;       // The funding goal in tokens.
        uint pledged;    // Total amount pledged by supporters.
        uint32 startAt;  // Campaign start timestamp.
        uint32 endAt;    // Campaign end timestamp.
        bool claimed;    // True if funds have been claimed by the creator after the campaign ended successfully.
    }


    // >> State Variables << //
    // Reference to the token contract used for pledges.
    IERC20 public immutable token;
    // Counter for the total number of campaigns created.
    uint public count;
    // Mapping from campaign ID to campaign data.
    mapping(uint => Campaign) public campaigns;
    // Mapping from campaign ID to supporter address to amount pledged.
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    // Constructor sets the token contract address.
    constructor(address _token) {
        token = IERC20(_token);
    }

    // Launch a new crowdfunding campaign.
    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt >= _startAt, "end at < start at");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");

        // Increment campaign counter and create new campaign.
        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        // Log the campaign launch.
        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    // Allow the creator to cancel a campaign before it starts.
    function cancel(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "not creator");
        require(block.timestamp < campaign.startAt, "started");

        // Remove the campaign.
        delete campaigns[_id];
        emit Cancel(_id);
    }

    // Support a campaign by pledging tokens.
    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "not started");
        require(block.timestamp <= campaign.endAt, "ended");

        // Increase pledged amount and record the pledge.
        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    // Withdraw a pledge before the campaign ends.
    function unpledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endAt, "ended");

        // Decrease pledged amount and return tokens.
        campaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }

    // Creator claims the pledged funds after the campaign ends successfully.
    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "not creator");
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged >= campaign.goal, "pledged < goal");
        require(!campaign.claimed, "claimed");

        // Mark as claimed and transfer the funds.
        campaign.claimed = true;
        token.transfer(campaign.creator, campaign.pledged);

        emit Claim(_id);
    }

    // Allow pledgers to claim refunds if the campaign did not reach its goal.
    function refund(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged < campaign.goal, "pledged >= goal");

        // Calculate refund amount and reset pledged amount.
        uint bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }
}
