// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AutmotiveContract {
    // state variables
    address public owner;
    mapping(address => bool) public buyers;
    string public vehicleMake;
    string public vehicleModel;
    uint public vehiclePrice;

    // Purchase event to log Purchase transaction event
    event Purchase(address buyer, string vehicleMake, string vehicleModel, uint vehiclePrice);

    // constructor
    // constructor - is an optional function that is executed upon contract creation. 
    constructor() {
        owner = msg.sender;
    }

    // function to buy a vehicle
    function buyVehicle(string memory _vehicleMake, string memory _vehicleModel) public payable {
        require(msg.value >= vehiclePrice);
        require(buyers[msg.sender] == false);
        vehicleMake = _vehicleMake;
        vehicleModel = _vehicleModel;
        buyers[msg.sender] = true;

        emit Purchase(msg.sender, _vehicleMake, _vehicleModel, vehiclePrice);
    }

    // function to set price of the vehicle
    function setPrice(uint _vehiclePrice) public {
        require(msg.sender == owner);
         vehiclePrice = _vehiclePrice;
    }

    // function to check ownership
    function checkOwnership() public view returns (bool) {
        return buyers[msg.sender];
    }
}