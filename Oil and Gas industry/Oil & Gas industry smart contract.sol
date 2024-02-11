// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OilAndGas {
    address public owner;
    mapping (string => OilWell) public wells;

    struct OilWell {
        string name;
        address operator;
        uint256 production;
    }

    event OilWellCreated(string indexed _wellName, address indexed _operator);
    event ProductionChanged(string indexed  _wellName, uint256 indexed _production);

    constructor () {
        owner = msg.sender;
    }

    function createOilWell(string memory _wellName) public {
        wells[_wellName] = OilWell(_wellName, msg.sender, 0);
        emit OilWellCreated(_wellName, msg.sender);
    }

    function changeOperator(string memory _wellName, address _newOperator) public {
        require(msg.sender == owner, "Sender must be the owner of the contract.");
        wells[_wellName].operator = _newOperator;
    }

    function updateProduction (string memory _wellName, uint256 _production) public {
        require(msg.sender == wells[_wellName].operator, "Sender must be the owner of the contract");
        wells[_wellName].production = _production;
        emit ProductionChanged(_wellName, _production);
    }

    function checkWell(string memory _wellName) public view  returns  (string memory, address, uint256) {
        return (wells[_wellName].name, wells[_wellName].operator, wells[_wellName].production);
    }
}