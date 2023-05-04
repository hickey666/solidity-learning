// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    // 代币总供给
    uint256 public override totalSupply;

    // 代币名称
    string public name;
    // 代币符号
    string public symbol;
    // 代币小数位数
    uint8 public decimals = 18;

    // 在合约部署的时候实现合约名称和符号
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    // 实现代币转账
    function transfer(
        address recipient,
        uint amount
    ) external override returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // 实现代币授权
    function approve(
        address spender,
        uint amount
    ) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 实现代币授权转账
    function transferFrom(
        address spender,
        address recipient,
        uint amount
    ) external override returns (bool) {
        balanceOf[spender] -= amount;
        allowance[spender][msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(spender, recipient, amount);
        return true;
    }

    // 铸造代币，从 `0` 地址转账给 调用者地址
    function mint(uint ammount) external {
        balanceOf[msg.sender] += ammount;
        totalSupply += ammount;
        emit Transfer(address(0), msg.sender, ammount);
    }

    // 销毁代币，从 调用者地址 转账给  `0` 地址
    function burn(uint ammount) external {
        balanceOf[msg.sender] -= ammount;
        totalSupply -= ammount;
        emit Transfer(msg.sender, address(0), ammount);
    }
}

contract Faucet {
    uint256 public amountAllowed = 100; // 每次申请代币的数量
    address public tokenContract; // 代币合约地址
    mapping(address => bool) public requestedAddress; // 记录领取过的代币地址

    event SendToken(address indexed Receiver, uint256 indexed Amount);

    constructor(address _tokenContract) {
        tokenContract = _tokenContract;
    }

    function requestAddress() external {
        require(!requestedAddress[msg.sender], "You have already requested"); // 每个地址只能申请一次
        IERC20 token = IERC20(tokenContract); // 创建IERC20合约对象
        require(
            token.balanceOf(address(this)) >= amountAllowed,
            "Not enough token"
        ); // 水龙头空了

        token.transfer(msg.sender, amountAllowed); // 发送token
        requestedAddress[msg.sender] = true; // 记录领取的地址

        emit SendToken(msg.sender, amountAllowed); // 释放SendToken事件
    }
}
