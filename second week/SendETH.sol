// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// 3种方法发送ETH
// transfer: 2300 gas, revert
// send: 2300 gas, return bool
// call: all gas, return (bool, data)

error SendFailed();
error CallFailed();

contract SendETH {
    // 构造函数，payable使得部署的时候可以转eth进去
    constructor() payable {}

    // receive函数，接收eth时被触发
    receive() external payable {}

    // 1. transfer
    function transferETH(address payable _to, uint256 amount) external payable {
        _to.transfer(amount);
    }

    // 2. send
    function sendETH(address payable _to, uint256 amount) external payable {
        bool success = _to.send(amount);
        if (!success) {
            revert SendFailed();
        }
    }

    // 3. call
    function callETH(address payable _to, uint256 amount) external payable {
        (bool success, ) = _to.call{value: amount}("");
        if (!success) {
            revert CallFailed();
        }
    }
}

contract ReceiveETH {
    event Log(uint amount, uint gas);

    // receive函数，接收eth时被触发
    receive() external payable {
        emit Log(msg.value, gasleft());
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
