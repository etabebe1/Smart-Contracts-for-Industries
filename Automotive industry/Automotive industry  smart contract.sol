// SPDX-License-Identifier: MIT
pragma solidity ^0.8.00;


// Another example of a smart contract 
// that allows users to buy and sell vehicles 
// while also providing access to vehicle specifications:
contract VehicleMarketplace {
    struct Vehicle {
        string make;
        string model;
        uint256 price;
        uint256 vehicleId;
        bool isSold;
        address payable seller;
        address buyer;
    }

    Vehicle[] public vehicles;

    event VehicleListed(uint256 indexed vehicleId, string make, string model, uint256 price, address indexed seller);
    event VehicleSold(uint256 indexed vehicleId, address indexed seller, address indexed buyer, uint256 price);

    function listVehicle(string memory _make, string memory _model, uint256 _price, uint256 _vehicleId) public {
        Vehicle memory newVehicle = Vehicle({
            make: _make,
            model: _model,
            price: _price,
            vehicleId: _vehicleId,
            isSold: false,
            seller: payable(msg.sender),
            buyer: address(0)
        });

        vehicles.push(newVehicle);

        emit VehicleListed(vehicles.length - 1, _make, _model, _price, msg.sender);
    }

    function buyVehicle(uint256 _vehicleId) public payable {
        Vehicle storage vehicle = vehicles[_vehicleId];

        require(!vehicle.isSold, "Vehicle already sold");
        require(msg.value >= vehicle.price, "Insufficient funds");

        vehicle.isSold = true;
        vehicle.buyer = msg.sender;
        vehicle.seller.transfer(msg.value);

        emit VehicleSold(_vehicleId, vehicle.seller, msg.sender, vehicle.price);
    }

    function getVehicle(uint256 _vehicleId) public view returns (string memory, string memory, uint256, bool, address, address) {
        Vehicle storage vehicle = vehicles[_vehicleId];

        return (
            vehicle.make,
            vehicle.model,
            vehicle.price,
            vehicle.isSold,
            vehicle.seller,
            vehicle.buyer
        );
    }

    function getTotalVehicles() public view returns (uint256) {
        return vehicles.length;
    }
}


// In this smart contract, users can list vehicles for sale 
// by calling the listVehicle function 
// and providing the make, model, and price of the vehicle. 
// The buyVehicle function allows users to purchase a listed vehicle
//  by providing the corresponding vehicle ID and sending the required funds.
//  Once a vehicle is sold, the ownership is transferred, and the seller receives the payment.

// The getVehicle function allows users to retrieve the details
//  of a specific vehicle by providing its ID.
//  The getTotalVehicles function returns the total number 
// of vehicles listed in the marketplace.