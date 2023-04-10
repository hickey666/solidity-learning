// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Owner {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _; // 如果是的话，继续运行函数主体；否则报错并revert交易
    }

    // 定义一个带onlyOwner修饰符的函数
    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner; // 只有owner地址运行这个函数，并改变owner
    }
}
