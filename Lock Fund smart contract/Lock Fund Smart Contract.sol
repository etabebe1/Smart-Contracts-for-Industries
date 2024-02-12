// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract LockFund {
    address payable public owner;
    mapping (address => uint) public lockedFunds;
    mapping (address => uint) public lockedTimestamps;
    uint256 public lockDuration = 2 days;

    constructor () {
        owner = payable (msg.sender);
    }

    function lockFund (uint _value) public payable {
        require(msg.value >= _value);
        lockedFunds[msg.sender] = _value;
        lockedTimestamps[msg.sender] = block.timestamp;
    }

    function releaseFund () public {
        require(block.timestamp >= lockedTimestamps[msg.sender] + lockDuration, "Please wait till the time lock get ends.");
        payable (owner).transfer(lockedFunds[msg.sender]);
        delete lockedFunds[msg.sender];
        delete lockedTimestamps[msg.sender];
    }

    function withdraw () public {
        require(msg.sender == owner, "Only owner can withdarw the funds");
        require(address(this).balance > 0, "No fund availabel to withdraw.");
        payable (owner).transfer(address(this).balance);
    }

}