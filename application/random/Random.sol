// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../erc721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomNumber is ERC721, VRFConsumerBase {
    // NFT参数
    uint256 public totalSupply = 100; // NFT总量
    uint256[100] public ids; // 用于计算可以mint的token id
    uint256 public mintCount; // 已经mint的数量

    // chainlink VRF参数
    bytes32 internal keyHash; // VRF 唯一标识符
    uint256 internal fee; // VRF 手续费

    // 记录VRF申请标识对应的mint地址
    mapping(bytes32 => address) public requestIdToSender;

    /**
     * 使用chainlink VRF，构造函数需要继承 VRFConsumerBase
     * 不同链参数填的不一样
     * 网络: Rinkeby测试网
     * Chainlink VRF Coordinator 地址: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     * LINK 代币地址: 0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     */
    constructor()
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709 // LINK Token
        )
        ERC721("HTF Random Number", "HTFRN")
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
    }

    /**
     * 输入uint256数字，返回一个可以mint的tokenId
     */
    function pickRandomUniqueId(
        uint256 random
    ) private returns (uint256 tokenId) {
        // 先计算减法，再计算++，关注(a++, ++a)区别
        uint256 len = totalSupply - mintCount++; // 可mint数量
        require(len > 0, "mint close");
        uint256 randomIndex = random % len; // 随机数对可mint数量取余

        // 随机数取模，得到tokenId，作为数组下标，同时记录value为len-1，如果取模得到的值已经存在，则tokenId取该数组下标的value
        tokenId = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex;
        ids[randomIndex] = ids[len - 1] == 0 ? len - 1 : ids[len - 1];
        ids[len - 1] = 0;
    }

    /**
     * 链上伪随机数生成
     * keccak256(abi.encodePacked()中填上一些链上的全局变量/自定义变量
     * 返回时转换成uint256类型
     */
    function getRandomOnChain() public view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        abi.encodePacked(
                            blockhash(block.number - 1),
                            msg.sender,
                            block.timestamp
                        )
                    )
                )
            );
    }

    // 利用链上伪随机数生成NFT
    function mintRandomOnChain() public {
        uint256 _tokenId = pickRandomUniqueId(getRandomOnChain());
        _mint(msg.sender, _tokenId);
    }

    /**
     * 调用VRF获取随机数，并mintNFT
     * 要调用requestRandomness()函数获取，消耗随机数的逻辑写在VRF的回调函数fulfillRandomness()中
     * 调用前，把LINK代币转到本合约里
     */
    function mintRandomVRF() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
        requestId = requestRandomness(keyHash, fee);
        requestIdToSender[requestId] = msg.sender;
    }

    /**
     * VRF的回调函数，由VRF Coordinator调用
     * 消耗随机数的逻辑写在本函数中
     */
    function fulfillRandomness(
        bytes32 requestId,
        uint256 randomness
    ) internal override {
        uint256 _tokenId = pickRandomUniqueId(randomness);
        _mint(requestIdToSender[requestId], _tokenId);
    }
}
