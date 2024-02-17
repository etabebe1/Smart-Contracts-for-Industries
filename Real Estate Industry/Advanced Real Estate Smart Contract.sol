// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AdvancedRealEstate {
    using SafeMath for uint256;

    address private _owner;
    mapping(uint256 => Property) public properties;
    uint256[] public propertyIds;

    struct Property {
        uint256 price;
        address owner;
        bool forSale;
        string name;
        string location;
        string description;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event PropertyListed(uint256 propertyId, uint256 price, string name, string location);
    event PropertySold(uint256 propertyId, address buyer, uint256 price);

    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function listPropertyForSale(
        uint256 propertyId,
        uint256 price,
        string memory name,
        string memory location,
        string memory description
    ) public onlyOwner {
        Property memory newProperty = Property({
            price: price,
            owner: msg.sender,
            forSale: true,
            name: name,
            location: location,
            description: description
        });

        properties[propertyId] = newProperty;
        propertyIds.push(propertyId);

        emit PropertyListed(propertyId, price, name, location);
    }

    function buyProperty(uint256 propertyId) public payable {
        Property storage property = properties[propertyId];

        require(property.forSale, "Property is not for sale.");
        require(property.price <= msg.value, "Insufficient funds");

        address previousOwner = property.owner;
        property.owner = msg.sender;
        property.forSale = false;

        payable(previousOwner).transfer(msg.value);

        emit PropertySold(propertyId, msg.sender, msg.value);
    }

    function owner() public view returns (address) {
        return _owner;
    }
}
