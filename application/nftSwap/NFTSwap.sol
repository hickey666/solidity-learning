// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../erc721/IERC721.sol";
import "../erc721/IERC721Receiver.sol";
import "../erc721/HApe.sol";

contract NFTSwap is IERC721Receiver {
    event List(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price
    );
    event Purchase(
        address indexed buyer,
        address indexed nftAddr,
        uint256 tokenId,
        uint256 price
    );
    event Revoke(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId
    );
    event Update(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 newPrice
    );

    // 定义order结构体
    struct Order {
        address owner;
        uint256 price;
    }
    // NFT Order映射
    mapping(address => mapping(uint256 => Order)) public nftList;

    fallback() external payable {}

    // 挂单：卖家上架NFT，合约地址为_nftAddr，tokenId为_tokenId，价格_price为以太坊（单位是wei）
    function list(address _nftAddr, uint256 _tokenId, uint256 _price) public {
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.getApproved(_tokenId) == address(this), "Not approved"); // 合约得到授权
        require(_price > 0); // 价格大于0

        Order storage _order = nftList[_nftAddr][_tokenId]; // 设置NFT Order
        _order.owner = msg.sender; // 设置卖家地址
        _order.price = _price; // 设置价格

        _nft.safeTransferFrom(msg.sender, address(this), _tokenId); // 转移NFT到合约地址

        emit List(msg.sender, _nftAddr, _tokenId, _price); // 触发List事件
    }

    // 购买：买家购买NFT，合约地址为_nftAddr，tokenId为_tokenId，调用函数时要附带ETH
    function purchase(address _nftAddr, uint256 _tokenId) public payable {
        Order storage _order = nftList[_nftAddr][_tokenId]; // 设置NFT Order
        require(_order.price > 0, "Invalid Price"); // NFT价格大于0
        require(msg.value >= _order.price, "Increase price"); // 购买价格大于标价

        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); // NFT在合约中

        _nft.safeTransferFrom(address(this), msg.sender, _tokenId); // 转移NFT到买家地址

        payable(_order.owner).transfer(_order.price); // 转移ETH到卖家地址
        payable(msg.sender).transfer(msg.value - _order.price); // 将多余的ETH给买家退款

        delete nftList[_nftAddr][_tokenId]; // 删除NFT Order

        emit Purchase(msg.sender, _nftAddr, _tokenId, _order.price); // 触发Purchase事件
    }

    // 撤单：卖家取消挂单
    function revoke(address _nftAddr, uint256 _tokenId) public {
        Order storage _order = nftList[_nftAddr][_tokenId]; // 设置NFT Order
        require(_order.owner == msg.sender, "Not owner"); // 只有卖家可以撤单

        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); // NFT在合约中

        _nft.safeTransferFrom(address(this), msg.sender, _tokenId); // 转移NFT到卖家地址

        delete nftList[_nftAddr][_tokenId]; // 删除NFT Order

        emit Revoke(msg.sender, _nftAddr, _tokenId); // 触发Revoke事件
    }

    // 调整价格：卖家调整挂单价格
    function update(
        address _nftAddr,
        uint256 _tokenId,
        uint256 _newPrice
    ) public {
        require(_newPrice > 0, "Invalid Price"); // NFT价格大于0

        Order storage _order = nftList[_nftAddr][_tokenId]; // 设置NFT Order
        require(_order.owner == msg.sender, "Not owner"); // 只有卖家可以调整价格

        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); // NFT在合约中

        _order.price = _newPrice; // 设置新价格

        emit Update(msg.sender, _nftAddr, _tokenId, _newPrice); // 触发Update事件
    }

    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
