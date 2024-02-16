// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import SafeMath library from OpenZeppelin for safe arithmetic operations
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Define the RealEstate contract
contract RealEstate {
    // Enable SafeMath for uint256 to prevent overflow/underflow
    using SafeMath for uint256;

    // Define a structure to represent a property
    struct Property {
        uint256 price; // Price of the property
        address owner; // Owner of the property
        bool forSale; // Whether the property is for sale
        string name; // Name of the property
        string location; // Location of the property
        string description; // Description of the property
    }

    // Mapping from property ID to Property struct
    mapping (uint256 => Property) public properties;
    // Array to store all property IDs
    uint256[] public PropertyIds;

    // Event to be emitted when a property is sold
    event PropertySold(uint256 propertyId);

    // Function to list a property for sale
    function listPropertyForSale (
        uint256 _propertyId,
        uint256 _price, 
        string memory _name,
        string memory _location, 
        string memory _description
        ) external {
            // Create a new Property struct and add it to the mapping
            Property memory newProperty = Property ({
                price: _price,
                owner: msg.sender,
                forSale: true,
                name: _name,
                location: _location,
                description: _description
            });

            properties[_propertyId] = newProperty;
            PropertyIds.push(_propertyId); // Add property ID to the array
        }

    // Function to buy a property
    function buyProperty (uint256 _propertyId) external payable {
        // Reference the property from the mapping
        Property storage property = properties[_propertyId];

        // Check that the property is for sale and that the sender sent enough value
        require(property.forSale, "Property is not for sale.");
        require(property.price <= msg.value, "Insufficient funds");

        // Update the property's status and owner
        property.owner = msg.sender;
        property.forSale = false;

        // Transfer the payment to the former owner
        payable (property.owner).transfer(property.price);

        // Emit the PropertySold event
        emit PropertySold(_propertyId);
    }
}
