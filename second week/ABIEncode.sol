// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ABIEncode {
    uint x = 10;
    address addr = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71;
    string name = "0xAA";
    uint[2] array = [5, 6];

    function encode() public view returns (bytes memory result) {
        result = abi.encode(x, addr, name, array);
    }

    function encodePacked() public view returns (bytes memory result) {
        result = abi.encodePacked(x, addr, name, array);
    }

    function encodeWithSignature() public view returns (bytes memory result) {
        result = abi.encodeWithSignature(
            "foo(uint256,address,string,uint256[2])",
            x,
            addr,
            name,
            array
        );
    }

    function encodeWithSelector() public view returns (bytes memory result) {
        result = abi.encodeWithSelector(
            bytes4(keccak256("foo(uint256,address,string,uint256[2])")),
            x,
            addr,
            name,
            array
        );
    }

    function decode(
        bytes memory data
    ) public pure returns (uint, address, string memory, uint[2] memory) {
        (
            uint _x,
            address _addr,
            string memory _name,
            uint[2] memory _array
        ) = abi.decode(data, (uint, address, string, uint[2]));
        return (_x, _addr, _name, _array);
    }
}
