// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract OnlyEven {
    constructor(uint a) {
        require(a != 0, "invalid number");
        assert(a != 1);
    }

    function onlyEven(uint256 b) external pure returns (bool success) {
        require(b % 2 == 0, "Ups! Reverting");
        success = true;
    }
}

contract TryCatch {
    event SuccessEvent();
    event CatchEvent(string message);
    event CatchByte(bytes data);

    OnlyEven even;

    constructor() {
        even = new OnlyEven(2);
    }

    // 在external call中使用try-catch
    // execute(0)会成功并释放`SuccessEvent`
    // execute(1)会失败并释放`CatchEvent`
    function execute(uint amount) external returns (bool success) {
        try even.onlyEven(amount) returns (bool _success) {
            // call成功的情况下
            emit SuccessEvent();
            return _success;
        } catch Error(string memory message) {
            // call失败的情况下
            emit CatchEvent(message);
        }
    }

    function executeNew(uint a) external returns (bool success) {
        try new OnlyEven(a) returns (OnlyEven _even) {
            emit SuccessEvent();
            success = _even.onlyEven(a);
        } catch Error(string memory message) {
            emit CatchEvent(message);
        } catch (bytes memory data) {
            // catch失败的assert assert失败的错误类型是Panic(uint256) 不是Error(string)类型 故会进入该分支
            emit CatchByte(data);
        }
    }
}
