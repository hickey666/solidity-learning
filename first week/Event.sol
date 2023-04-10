// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Events {
    mapping(address => uint256) public _balance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function _transfer(address _from, address _to, uint256 _value) external {
        _balance[_from] = 10000000;

        _balance[_from] -= _value;
        _balance[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
}
