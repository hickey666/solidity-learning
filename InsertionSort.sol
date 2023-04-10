// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract InsertionSort {
    // if else
    function ifElseTest(uint256 _number) public pure returns (bool) {
        if (_number > 10) {
            return true;
        } else {
            return false;
        }
    }

    // for loop
    function forLoopTest() public pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 10; i++) {
            sum += i;
        }
        return sum;
    }

    // while loop
    function whileTest() public pure returns (uint256) {
        uint256 sum = 0;
        uint256 i = 0;
        while (i < 10) {
            sum += i;
            i++;
        }
        return sum;
    }

    // do while loop
    function doWhileTest() public pure returns (uint256) {
        uint256 sum = 0;
        uint256 i = 0;
        do {
            sum += i;
            i++;
        } while (i < 10);
        return sum;
    }

    // 三元运算符
    function ternaryTest(uint256 x, uint256 y) public pure returns (uint256) {
        return x > y ? x : y;
    }

    function sort(uint[] memory arr) public pure returns (uint[] memory) {
        uint len = arr.length;
        for (uint i = 1; i < len; i++) {
            uint temp = arr[i];
            uint j = i;
            while (j > 0 && arr[j - 1] > temp) {
                arr[j] = arr[j - 1];
                j--;
            }
            arr[j] = temp;
        }
        return arr;
    }
}
