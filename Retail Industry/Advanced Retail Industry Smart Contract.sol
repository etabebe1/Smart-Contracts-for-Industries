// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Advanced Retail Smart Contract with features like dynamic pricing, loyalty points, and product categories.
contract AdvancedRetail {
    // Define a product with properties including name, price, stock, loyalty points, and category.
    struct Product {
        bytes32 name;
        uint256 price;
        uint256 stock;
        uint256 loyaltyPoints;
        bytes32 category;
    }
    
    // Define a discount structure with percentage and validity period.
    struct Discount {
        uint256 percentage;
        uint256 validUntil;
    }

    // Mapping from product name to its details.
    mapping(bytes32 => Product) public products;
    // Mapping from customer address to their loyalty points balance.
    mapping(address => uint256) public loyaltyPoints;
    // Mapping from product name to its current discount.
    mapping(bytes32 => Discount) public discounts;
    // Mapping from category to list of products within it.
    mapping(bytes32 => bytes32[]) public categoryProducts;

    // Owner of the smart contract.
    address payable owner;
    
    // Events for logging actions within the contract.
    event ProductAdded(bytes32 indexed name, uint256 price, uint256 stock);
    event ProductPurchased(address indexed buyer, bytes32 indexed name, uint256 quantity);
    event PriceUpdated(bytes32 indexed name, uint256 newPrice);
    event StockUpdated(bytes32 indexed name, uint256 newStock);
    event DiscountApplied(bytes32 indexed name, uint256 discountPercentage);
    event LoyaltyPointsEarned(address indexed customer, uint256 points);
    
    // Modifier to restrict function access to the owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    // Constructor to set the contract's owner upon deployment.
    constructor() {
        owner = payable(msg.sender);
    }

    // Function to add a new product to the store.
    function addProduct(bytes32 name, uint256 price, uint256 stock, bytes32 category) external onlyOwner {
        products[name] = Product(name, price, stock, 0, category);
        categoryProducts[category].push(name);
        emit ProductAdded(name, price, stock);
    }

    // Function to update the price of an existing product.
    function updateProductPrice(bytes32 name, uint256 newPrice) external onlyOwner {
        products[name].price = newPrice;
        emit PriceUpdated(name, newPrice);
    }

    // Function to update the stock quantity of an existing product.
    function updateProductStock(bytes32 name, uint256 newStock) external onlyOwner {
        products[name].stock = newStock;
        emit StockUpdated(name, newStock);
    }

    // Function to apply a discount to a product.
    function applyDiscount(bytes32 name, uint256 discountPercentage, uint256 duration) external onlyOwner {
        discounts[name] = Discount(discountPercentage, block.timestamp + duration);
        emit DiscountApplied(name, discountPercentage);
    }

    // Function allowing customers to purchase products.
    function purchaseProduct(bytes32 name, uint256 quantity) external payable {
        Product storage product = products[name];
        require(quantity <= product.stock, "Not enough stock.");
        uint256 effectivePrice = calculatePrice(name, product.price, quantity);
        require(msg.value >= effectivePrice, "Insufficient funds.");

        product.stock -= quantity;
        loyaltyPoints[msg.sender] += quantity * product.loyaltyPoints;
        emit ProductPurchased(msg.sender, name, quantity);
        emit LoyaltyPointsEarned(msg.sender, quantity * product.loyaltyPoints);
    }

    // Function to calculate the price of a product, taking into account any applicable discounts.
    function calculatePrice(bytes32 name, uint256 basePrice, uint256 quantity) public view returns (uint256) {
        if (discounts[name].validUntil > block.timestamp) {
            uint256 discountValue = basePrice * discounts[name].percentage / 100;
            return (basePrice - discountValue) * quantity;
        }
        return basePrice * quantity;
    }

    // Function to set loyalty points that customers earn when purchasing a specific product.
    function addLoyaltyPointsToProduct(bytes32 name, uint256 points) external onlyOwner {
        products[name].loyaltyPoints = points;
    }

    // Additional features such as managing categories, redeeming loyalty points, etc., can be added here.
}
