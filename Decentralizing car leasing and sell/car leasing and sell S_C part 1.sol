// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; // Sets the compiler version to 0.8.0 or newer.

// Declares a new contract for car leasing and sales.
contract CarLeasingAndSales {
    // Defines a Car struct with properties relevant to leasing and selling.
    struct Car {
        address owner; // The current owner of the car.
        uint256 price; // Sale price of the car.
        uint256 deposit; // Deposit required to lease the car.
        uint256 leaseTerm; // Duration of the lease in days.
        uint256 leaseEnd; // Timestamp when the lease ends.
        bool isLeased; // Indicates whether the car is currently leased.
    }

    // A mapping to store car information for each address.
    mapping (address => Car) public cars;
    uint256 public carCount; // Counts the total number of cars registered.

    // Events declaration for logging activities.
    event CarRegistered(address indexed owner, uint256 price, uint256 deposit, uint256 leaseTerm);
    event CarLeased(address indexed leasee, uint256 leaseEnd);
    event CarBought(address indexed buyer);

    // Initializes state variables in the constructor.
    constructor() {
        carCount = 0; // Starts counting cars from 0.
    }

    // Modifier to restrict function access to the car's owner.
    modifier onlyOwner(address _owner) {
        require(msg.sender == _owner, "Only the car owner can call this function.");
        _; // Continues execution after the require statement.
    }

    // Registers a car with the specified properties.
    function registerCar(uint256 _price, uint256 _deposit, uint256 _leaseTerm) public {
        require(_price > 0, "Price must be > 0");
        require(_deposit > 0, "Deposit must be greater than zero.");
        require(_leaseTerm > 0, "Lease term must be greater than zero.");
  
        // Creates a new Car struct and adds it to the mapping.
        Car memory car = Car(msg.sender, _price, _deposit, _leaseTerm, 0, false);
        cars[msg.sender] = car;
        carCount++; // Increments the car count.

        // Emits the CarRegistered event.
        emit CarRegistered(msg.sender, _price, _deposit, _leaseTerm);
    }

    // Allows a user to lease a car by paying the deposit.
    function leaseCar(address _carOwner) public payable {
        Car storage car = cars[_carOwner]; // Fetches the car from storage.

        // Checks for lease eligibility.
        require(car.owner != address(0), "Car owner not found.");
        require(!car.isLeased, "Car is already leased.");
        require(msg.value == car.deposit, "Sent amount must be equal to deposit amount.");

        // Updates the car's status to leased.
        car.isLeased = true;
        car.leaseEnd = block.timestamp + (car.leaseTerm * 1 days); // Calculates the lease end time.

        // Emits the CarLeased event.
        emit CarLeased(msg.sender, car.leaseEnd);
    }

    // Allows a user to buy a car by paying its price.
    function buyCar(address _carOwner) public payable {
        Car storage car = cars[_carOwner]; // Fetches the car from storage.

        // Checks if the car can be bought.
        require(car.owner != address(0), "Car owner not found.");
        require(!car.isLeased, "Car is currently leased.");
        require(msg.value == car.price, "Sent amount must be equal to car price,");

        // Transfers ownership of the car.
        car.owner = msg.sender;

        // Emits the CarBought event.
        emit CarBought(msg.sender);
    }    

    // Returns car details for a given owner address.
    function getCar(address _carOwner) public view returns (uint256, uint256, uint256, bool) {
        Car memory car = cars[_carOwner]; // Fetches the car from memory.
        // Returns relevant properties of the car.
        return (car.price, car.deposit, car.leaseTerm, car.isLeased);
    } 
}
