// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/escrow/Escrow.sol"; // Importing the Escrow contract from OpenZeppelin for managing deposits securely.

contract AdvancedCarLeasingAndSales {
    // Define the car structure with additional attributes for comprehensive management.
    struct Car {
        address owner; // Owner of the car.
        uint256 price; // Price of the car for sale.
        uint256 deposit; // Deposit required for leasing the car.
        uint256 leaseTerm; // Duration of the lease in seconds.
        bool forSale; // Indicates if the car is available for sale.
        bool forLease; // Indicates if the car is available for lease.
        address lessee; // Current lessee of the car.
        uint256 leaseStart; // Timestamp when the lease starts.
        uint256 leaseEnd; // Timestamp when the lease ends.
    }

    // State variables for managing cars and users.
    mapping(uint256 => Car) public cars; // Mapping from car ID to Car struct.
    mapping(address => uint256) public ownerReputation; // Mapping from owner address to their reputation score.
    mapping(address => uint256) public lesseeReputation; // Mapping from lessee address to their reputation score.
    uint256 public carCount = 0; // Counter to keep track of the total number of cars.
    Escrow private escrow; // Escrow contract instance for handling deposits.

    // Events for logging actions on the blockchain.
    event CarRegistered(uint256 carId, address owner, uint256 price, uint256 deposit, uint256 leaseTerm, bool forSale, bool forLease);
    event CarLeased(uint256 carId, address lessee, uint256 leaseStart, uint256 leaseEnd);
    event CarReturned(uint256 carId, address lessee);
    event CarBought(uint256 carId, address buyer);
    event ReputationUpdated(address user, uint256 newReputation);

    // Modifiers to enforce access control.
    modifier onlyOwner(uint256 carId) {
        require(cars[carId].owner == msg.sender, "Not the car owner.");
        _;
    }

    modifier onlyLessee(uint256 carId) {
        require(cars[carId].lessee == msg.sender, "Not the lessee.");
        _;
    }

    // Constructor to initialize the escrow contract.
    constructor() {
        escrow = new Escrow();
    }

    // Registers a new car with the specified details.
    function registerCar(uint256 _price, uint256 _deposit, uint256 _leaseTerm, bool _forSale, bool _forLease) public {
        uint256 carId = carCount++; // Assign a unique ID to the new car.
        // Create a new car struct and store it in the mapping.
        cars[carId] = Car(msg.sender, _price, _deposit, _leaseTerm, _forSale, _forLease, address(0), 0, 0);
        // Emit an event for the car registration.
        emit CarRegistered(carId, msg.sender, _price, _deposit, _leaseTerm, _forSale, _forLease);
    }

    // Allows a user to lease a car by paying the required deposit.
    function leaseCar(uint256 carId) public payable {
        Car storage car = cars[carId]; // Retrieve the car from the mapping.
        // Ensure the car is available for lease and the correct deposit is paid.
        require(car.forLease, "Car not available for lease.");
        require(msg.value == car.deposit, "Incorrect deposit amount.");
        require(car.lessee == address(0), "Car already leased.");

        // Update the car's lease details.
        car.lessee = msg.sender;
        car.leaseStart = block.timestamp;
        car.leaseEnd = block.timestamp + car.leaseTerm;
        // Deposit the lease amount into the escrow.
        escrow.deposit{value: msg.value}(msg.sender);

        // Emit an event for the car lease.
        emit CarLeased(carId, msg.sender, car.leaseStart, car.leaseEnd);
    }

    // Allows the lessee to return the car and retrieve their deposit.
    function returnCar(uint256 carId) public onlyLessee(carId) {
        Car storage car = cars[carId]; // Retrieve the car from the mapping.
        // Ensure the lease term hasn't ended.
        require(block.timestamp <= car.leaseEnd, "Lease term has ended.");

        // Reset the car's lease details.
        car.lessee = address(0);
        // Refund the deposit from the escrow to the lessee.
        escrow.withdraw(msg.sender);

        // Update reputations for both the lessee and the owner.
        updateReputation(car.owner, 1);
        updateReputation(msg.sender, 1);

        // Emit an event for returning the car.
        emit CarReturned(carId, msg.sender);
    }

    // Allows a user to buy a car.
    function buyCar(uint256 carId) public payable {
        Car storage car = cars[carId]; // Retrieve the car from the mapping.
        // Ensure the car is for sale and the correct price is paid.
        require(car.forSale, "Car not for sale.");
        require(msg.value == car.price, "Incorrect price.");

        // Transfer ownership and funds.
        address previousOwner = car.owner;
        car.owner = msg.sender;
        car.forSale = false;
        payable(previousOwner).transfer(msg.value);

        // Emit an event for the car purchase.
        emit CarBought(carId, msg.sender);
    }

    // Internal function to update a user's reputation.
    function updateReputation(address user, uint256 points) internal {
        ownerReputation[user] += points; // Increment the user's reputation by the specified points.
        // Emit an event for the reputation update.
        emit ReputationUpdated(user, ownerReputation[user]);
    }

    // Retrieves the details of a specific car.
    function getCarDetails(uint256 carId) public view returns (Car memory) {
        return cars[carId]; // Return the car struct for the given ID.
    }
}
