// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface Base {
    function getFistName() external pure returns (string memory);
    function getLastName() external pure returns (string memory);
}

contract BaseImpl is Base {
    function getFistName() public pure override returns (string memory) {
        return "Amazing";
    }
    
    function getLastName() public pure override returns (string memory) {
        return "Ang";
    }
}