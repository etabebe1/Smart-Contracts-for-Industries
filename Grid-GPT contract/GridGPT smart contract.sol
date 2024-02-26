// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Importing the ERC721 standard implementation from OpenZeppelin
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Declaring the smart contract which inherits from OpenZeppelin's ERC721
contract GPTMemebership is ERC721 {

    // State variables
    address public owner; // Stores the address of the contract owner
    uint256 public membershipTypes; // Counter for the number of membership types available
    uint256 public totalMemberships; // Counter for the total number of memberships minted

    string public MY_CONTRACT = "JEREMIAH T.A"; // Just a public string variable, possibly for identification
    
    // Structs for complex data
    struct Membership {
        uint256 id; // Unique ID for the membership
        string name; // Name of the membership
        uint256 cost; // Cost to acquire the membership
        string date; // Creation date or relevant date for the membership
    } 

    struct UserMembership {
        uint256 id; // Unique ID for the user's membership
        uint256 membershipId; // ID of the membership type
        address addressUser; // Address of the user owning the membership
        uint256 cost; // Cost paid for the membership
        string expireDate; // Expiration date for the membership
    }

    // Mappings for storing relationships
    mapping (address => UserMembership) userMemberships; // Maps a user address to their membership
    mapping (uint256 => Membership) memberships; // Maps a membership ID to the Membership struct
    mapping (uint256 => mapping (address => bool)) public hasBought; // Maps a membership ID and user address to a boolean representing if they've bought it
    mapping (uint256 => mapping (uint256 => address)) public membershipTaken; // Maps membership ID and user membership ID to the user's address
    mapping (uint256 => uint256[]) membershipsTaken; // Maps a membership ID to an array of user membership IDs

    // Modifier to restrict function calls to the owner only
    modifier onlyOwner () {
        require(msg.sender == owner, "Only owner can call this function.");
        _; // Continues execution of the modified function
    }

    // Constructor to initialize the contract
    constructor (
        string memory _name, 
        string memory _symbol
        ) ERC721 (_name, _symbol) { // Calls the ERC721 constructor with the name and symbol
            owner = msg.sender; // Sets the contract deployer as the owner
    } 

    // Function to create a new membership type
    function list (
        string memory _name, 
        uint256 _cost, 
        string memory _date
        ) public onlyOwner { // Can only be called by the owner
            membershipTypes++; // Increment the count of membership types
            memberships[membershipTypes] = Membership( // Adds the new membership to the mapping
                membershipTypes,
                _name,
                _cost,
                _date
            );
    }

    // Function to mint a new membership
    function mint (
        uint256 _membershipId, 
        address _user,
        string memory _expiredDate
    ) public payable { // Payable allows it to receive ETH
        require(_membershipId != 0, "Invalid membershipId"); // Membership ID must be valid
        require(_membershipId <= membershipTypes); // Membership ID must exist

        // Check if sent value is at least equal to the membership cost
        require(msg.value >= memberships[_membershipId].cost, "Insufficent funds");
        totalMemberships++; // Increment total memberships

        // Record the user's membership
        userMemberships[_user] = UserMembership(
            totalMemberships,
            _membershipId,
            _user,
            memberships[_membershipId].cost,
            _expiredDate
        );

        // Mark the membership as bought
        hasBought[_membershipId][msg.sender] = true;
        // Link the membership to the user
        membershipTaken[_membershipId][totalMemberships] = msg.sender;
        // Add the membership to the taken list
        membershipsTaken[_membershipId].push(totalMemberships);

        // Mint the NFT to the user
        _safeMint(msg.sender, totalMemberships);
    }

    // Function to get details of a membership
    function getMembership (uint256 _memebeshipId) public view returns (Membership memory) {
        return memberships[_memebeshipId]; // Return the membership details
    }

    // Function to get all memberships taken of a particular type
    function getMembershipTaken (uint256 _membershipId) public view returns (uint256[] memory) {
        return membershipsTaken[_membershipId]; // Return the list of memberships
    }

    // Function to withdraw contract balance to the owner's address
    function withdarw () public onlyOwner() {
        (bool success,) = owner.call{value: address(this).balance}(""); // Transfer all contract balance to owner
        require(success); // Ensure the transfer was successful
    }

    // Function to get a user's membership details
    function getUserMembership (address _address) public view returns (UserMembership memory) {
        return userMemberships[_address]; // Return the user's membership
    }
}
