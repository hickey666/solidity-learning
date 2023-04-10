// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Base {
    string public name = "Base";

    function getAlias() public virtual returns (string memory);
}

contract BaseImpl is Base {
    function getAlias() public override returns (string memory) {
        return "BaseImpl";
    }
}
