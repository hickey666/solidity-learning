// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract InitialValue {
    bool public _bool; // false
    string public _string; // ""
    int public _int; // 0
    uint public _uint; // 0
    address public _address; // 0x0000000

    enum ActionSet {
        Buy,
        Hold,
        Sell
    }
    ActionSet public _enum; // 第一个元素 0

    function fi() internal {} // internal空白方程

    function fe() external {} // external空白方程

    uint[8] public _staticArray; // [0,0,0,0,0,0,0,0]
    uint[] public _dynamicArray; // []
    mapping(uint => address) public _mapping; // {}

    // 所有成员设为其默认值的结构体 0, 0
    struct Student {
        uint id;
        uint score;
    }
    Student public student;

    // delete 操作符
    bool public _bool2 = true;

    function d() external {
        delete _bool2; // false
    }
}
