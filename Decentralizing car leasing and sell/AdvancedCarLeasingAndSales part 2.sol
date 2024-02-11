// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Main contract declaration
contract AdvancedCarLeasingAndSales {
    // A struct to represent car properties
    struct Car {
        uint256 id; // Unique identifier for the car
        address owner; // Owner's address
        uint256 price; // Sale price of the car
        uint256 deposit; // Deposit required to lease the car
        uint256 leaseTerm; // Duration of the lease in days
        uint256 leaseEnd; // Timestamp when the lease ends
        bool isAvailableForLease; // Flag to check if the car is available for lease
        bool isAvailableForSale; // Flag to check if the car is available for sale
    }

    // A struct to represent user statistics
    struct User {
        uint256 totalLeased; // Total cars leased by the user
        uint256 totalPurchased; // Total cars purchased by the user
    }

    // >> State Variable << //
    // Mapping from car ID to Car struct
    mapping(uint256 => Car) public cars;
    // Mapping from user address to User struct
    mapping(address => User) public users;
    // Counter to assign unique IDs to new cars
    uint256 public nextCarId;

    // Event declarations for logging actions
    event CarRegistered(uint256 indexed carId, address indexed owner);
    event CarLeased(uint256 indexed carId, address indexed leasee, uint256 leaseEnd);
    event CarPurchased(uint256 indexed carId, address indexed newOwner);
    event LeaseExtended(uint256 indexed carId, uint256 newLeaseEnd);

    // Registers a car with details provided by the owner
    function registerCar(uint256 price, uint256 deposit, uint256 leaseTerm, bool availableForLease, bool availableForSale) external {
        uint256 carId = nextCarId++;
        cars[carId] = Car(carId, msg.sender, price, deposit, leaseTerm, 0, availableForLease, availableForSale);
        emit CarRegistered(carId, msg.sender);
    }

    // Allows a user to lease a car by providing the car ID and deposit
    function leaseCar(uint256 carId) external payable {
        Car storage car = cars[carId];
        require(car.isAvailableForLease, "Car not available for lease.");
        require(msg.value == car.deposit, "Incorrect deposit amount.");
        require(car.leaseTerm > 0, "Invalid lease term.");

        car.leaseEnd = block.timestamp + (car.leaseTerm * 1 days);
        car.isAvailableForLease = false;
        users[msg.sender].totalLeased++;

        emit CarLeased(carId, msg.sender, car.leaseEnd);
    }

    // Allows a user to extend the lease on a car they have already leased
    function extendLease(uint256 carId) external payable {
        Car storage car = cars[carId];
        require(block.timestamp < car.leaseEnd, "Current lease has ended.");
        require(msg.value == car.deposit, "Incorrect deposit amount for extension.");

        car.leaseEnd += car.leaseTerm * 1 days;

        emit LeaseExtended(carId, car.leaseEnd);
    }

    // Allows a user to purchase a car
    function purchaseCar(uint256 carId) external payable {
        Car storage car = cars[carId];
        require(car.isAvailableForSale, "Car not available for sale.");
        require(msg.value == car.price, "Incorrect price paid.");

        car.owner = msg.sender;
        car.isAvailableForSale = false;
        users[msg.sender].totalPurchased++;

        emit CarPurchased(carId, msg.sender);
    }

    // Returns the details of a car by its ID
    function getCarDetails(uint256 carId) external view returns (Car memory) {
        return cars[carId];
    }

    // Returns the statistics for a user
    function getUserStats(address userAddress) external view returns (User memory) {
        return users[userAddress];
    }
}
