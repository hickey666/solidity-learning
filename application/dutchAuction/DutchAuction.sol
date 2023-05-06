// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../erc721/ERC721.sol";

contract DutchAuction is Ownable, ERC721 {
    uint256 public constant COLLECTOIN_SIZE = 10000; // NFT总量
    uint256 public constant AUCTION_START_PRICE = 1 ether; // 起始价格
    uint256 public constant AUCTION_END_PRICE = 0.1 ether; // 结束价格
    uint256 public constant AUCTION_TIME = 10 minutes; // 拍卖时长
    uint256 public constant AUCTION_DROP_INTERCAL = 1 minutes; // 拍卖降价间隔
    uint256 public constant AUCTION_DROP_PER_STEP =
        (AUCTION_START_PRICE - AUCTION_END_PRICE) /
            (AUCTION_TIME / AUCTION_DROP_INTERCAL); // 每次降价的价格
    uint256 public auctionStartTime; // 拍卖开始时间
    string private _baseTokenURI; // metadata URI
    uint256[] private _allTokens; // 记录所有的tokenId

    //设定拍卖起始时间：我们在构造函数中会声明当前区块时间为起始时间，项目方也可以通过`setAuctionStartTime(uint32)`函数来调整
    constructor() ERC721("HXJ Dutch Auction", "HXJ Dutch Auction") {
        auctionStartTime = block.timestamp;
    }

    /**
     * ERC721Enumerable中totalSupply函数的实现
     */
    function totalSupply() public view virtual returns (uint256) {
        return _allTokens.length;
    }

    /**
     * Private函数，在_allTokens中添加一个新的token
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokens.push(tokenId);
    }

    // 拍卖mint函数
    function auctionMint(uint256 quantity) external payable {
        uint256 _saleStartTime = uint256(auctionStartTime); // 建立local变量，减少gas花费
        // 检查是否设置起拍时间，拍卖是否开始
        require(
            _safeStartTime != 0 && block.timestamp >= _saleStartTime,
            "sale has not started yet"
        );
        // 检查是否超过NFT上限
        require(
            totalSupply() + quantity <= COLLECTOIN_SIZE,
            "not enough remaining reserved for auction to support desired mint amount"
        );

        // 计算mint成本
        uint256 totalCost = getAuctionPrice() * quantity;
        // 检查用户是否师傅足够的ETH
        require(msg.value >= totalCost, "need to send more ETH.");

        // mint NFT
        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = totalSupply();
            _mint(msg.sender, tokenId);
            _addTokenToAllTokensEnumeration(tokenId);
        }
        // 多余ETH退回
        if (msg.value > totalCost) {
            // 注意一下这里是否有重入的风险
            payable(msg.sender).transfer(msg.value - totalCost);
        }
    }

    // 获取拍卖实时价格
    function getAuctionPrice() public view returns (uint256) {
        if (block.timestamp < auctionStartTime) {
            return AUCTION_START_PRICE;
        } else if (block.timestamp - auctionStartTime >= AUCTION_TIME) {
            return AUCTION_END_PRICE;
        } else {
            uint256 currentStep = (block.timestamp - auctionStartTime) /
                AUCTION_DROP_INTERCAL;
            return AUCTION_START_PRICE - AUCTION_DROP_PER_STEP * currentStep;
        }
    }

    // auctionStartTime setter函数，onlyOwner
    function setAuctionStartTime(uint32 timestamp) external onlyOwner {
        auctionStartTime = timestamp;
    }

    // BaseURI
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    // BaseURI setter函数, onlyOwner
    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    // 提款函数，onlyOwner
    function withdrawMoney() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer faild.");
    }
}
