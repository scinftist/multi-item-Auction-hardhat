// SPDX-License-Identifier: MIT
// Double Linked List
// Created by sciNFTist.eth
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "OpenZeppelin/openzeppelin-contracts@4.8.0/contracts/utils/Checkpoints.sol";

import {DoubleLinkedLibrary} from "./library/DoubleLinkedLibrary.sol"; //DoubleLinkedLibrary.sol

pragma solidity ^0.8.0;

contract MAuctionHouse {
    using DoubleLinkedLibrary for DoubleLinkedLibrary.DList;

    IERC721 public tok;

    // mapping(uint256 => DoubleLinkedLibrary.DList) private DLMap;
    //maybe insert number of token instead of firstTokenId and LastTokenID ~ justBalanceOf()
    //if they diidnt claim in claim
    struct MAuction {
        uint256 firstTokenId;
        uint256 lastTokenId;
        uint256 startTime;
        uint256 endTime;
        bool settled;
    }
    mapping(uint256 => DoubleLinkedLibrary.DList) private bidderListMap;
    mapping(uint256 => MAuction) private mAuctions;
    DoubleLinkedLibrary.DList private OOO;
    uint256 private c;
    // MAuction private mAuction;
    uint256 private timeBuffer;
    uint256 private reservePrice;
    uint256 private duration = 300;
    uint256 private turnDuration = 60;
    uint8 public minBidIncrementPercentage = 2;
    bool private initialized = false;

    /**
     * @notice Initialize the auction house and base contracts,
     * populate configuration values, and pause the contract.
     * @dev This function can only be called once.
     */
    function initialize(
        IERC721 _tok,
        // address _weth,
        uint256 _timeBuffer,
        uint256 _reservePrice,
        uint8 _minBidIncrementPercentage,
        uint256 _duration
    ) external {
        require(!initialized, "already initialized");
        // __Pausable_init();
        // __ReentrancyGuard_init();
        // __Ownable_init();
        require(_tok.balanceOf(address(this)) > 0, "Init with bad balance");
        tok = _tok;
        // weth = _weth;
        timeBuffer = _timeBuffer;
        reservePrice = _reservePrice;
        minBidIncrementPercentage = _minBidIncrementPercentage;
        duration = _duration;
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + duration * 2;
        uint256 firstToken = 0;
        uint256 lastToken = tok.balanceOf(address(this)) - 1;
        bidderListInit();
        mAuctions[c] = MAuction({
            firstTokenId: firstToken,
            lastTokenId: lastToken,
            startTime: startTime,
            endTime: endTime,
            settled: false
        });
        // bidderListMap[c] = DoubleLinkedLibrary.DList;

        // _pause();

        // nouns = _nouns;
        // weth = _weth;
        // timeBuffer = _timeBuffer;
        // reservePrice = _reservePrice;
        // minBidIncrementPercentage = _minBidIncrementPercentage;
        // duration = _duration;

        initialized = true;
    }

    //--------------------BidderList Init-----------

    function bidderListInit() private {
        c++;

        bidderListMap[c].init0();
    }

    //------------ BidderList view
    function getCounter() public view returns (uint256) {
        return bidderListMap[c].getCounter();
    }

    function getData(uint256 pos) public view returns (uint256) {
        return bidderListMap[c].getData(pos);
    }

    function getBidder(uint256 pos) public view returns (address) {
        return bidderListMap[c].getBidder(pos);
    }

    function getIndex(uint256 pos) public view returns (uint256) {
        return bidderListMap[c].getIndex(pos);
    }

    function getPrev(uint256 pos) public view returns (uint256) {
        return bidderListMap[c].getPrev(pos);
    }

    function getNext(uint256 pos) public view returns (uint256) {
        return bidderListMap[c].getNext(pos);
    }

    function getLen() public view returns (uint256) {
        return bidderListMap[c].getLen();
    }

    function getHead() public view returns (uint256) {
        return bidderListMap[c].getHead();
    }

    function getTail() public view returns (uint256) {
        return bidderListMap[c].getTail();
    }

    function posValidator(
        uint256 _pos,
        uint256 data
    ) public view returns (bool) {
        return bidderListMap[c].posValidator(_pos, data);
    }

    function findPos(uint256 data) public view returns (uint256) {
        return bidderListMap[c].findPos(data);
    }

    function removeThis(uint256 _pos) public {
        bidderListMap[c].removeThis(_pos);
    }

    function setSort(uint256 _pos, uint256 data) public {
        bidderListMap[c].setSort(_pos, data, msg.sender);
    }

    function numberOfItem() public view returns (uint256) {
        return (mAuctions[c].lastTokenId - mAuctions[c].firstTokenId) + 1;
    }

    function isBidable(uint256 val) public view returns (bool) {
        if (val < reservePrice) {
            return false;
        }

        if (getLen() < numberOfItem()) {
            return true;
        } else {
            uint256 tailPointer = getTail();
            uint256 tailValue = getData(tailPointer);
            address tailAddress = getBidder(tailPointer);
            if (
                val <
                tailValue + ((tailValue * minBidIncrementPercentage) / 100)
            ) {
                return false;
            }
            return true;
        }
    }

    ///----------Auction status
    //  MAuction({
    //         firstTokenId: firstToken,
    //         lastTokenId: lastToken,
    //         startTime: startTime,
    //         endTime: endTime,
    //         settled: false
    //     });
    function getStartTime() public view returns (uint256) {
        return mAuctions[c].startTime;
    }

    function getEndTime() public view returns (uint256) {
        return mAuctions[c].endTime;
    }

    function getSettled() public view returns (bool) {
        return mAuctions[c].settled;
    }

    ///---------finish--------
    function finishIt() public {
        require(!bidderListMap[c].isFinished(), "finishing err0");
        bidderListMap[c].finish();
        bidderListMap[c].index0(bidderListMap[c].getTail());
    }

    // if end?

    /////////////Bidding

    function createBid(uint256 pos) external payable {
        // INounsAuctionHouse.Auction memory _auction = auction;

        require(block.timestamp < mAuctions[c].endTime, "Auction expired");
        require(msg.value >= reservePrice, "Must send at least reservePrice");
        //------
        if (getLen() < numberOfItem()) {
            setSort(pos, msg.value);
            // whiteListed[msg.sender];
            // emit val(msg.value);
        } else {
            uint256 tailPointer = getTail();
            uint256 tailValue = getData(tailPointer);
            address tailAddress = getBidder(tailPointer);
            // require(msg.value >= tailValue, "?!?");
            require(
                msg.value >=
                    tailValue + ((tailValue * minBidIncrementPercentage) / 100),
                "Must send more than last bid by minBidIncrementPercentage amount"
            );
            // emit val(msg.value);
            // emit val(tailValue);

            setSort(pos, msg.value);
            removeThis(tailPointer);
            _safeTransferETHWithFallback(tailAddress, tailValue);
        }
    }

    ///--------settle make the -- make list immutable -- indexing calim --

    function _createAuction() internal {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + duration;
        bidderListInit();
        mAuctions[c] = MAuction({
            firstTokenId: 0,
            lastTokenId: 3,
            startTime: startTime,
            endTime: endTime,
            settled: false
        });
        // bidderListMap[c] = DoubleLinkedLibrary.DList;
    }

    function create() public {
        _createAuction();
    }

    /**
     * @notice Transfer ETH. If the ETH transfer fails, wrap the ETH and try send it as WETH.
     */
    function _safeTransferETHWithFallback(address to, uint256 amount) internal {
        if (!_safeTransferETH(to, amount)) {
            // IWETH(weth).deposit{ value: amount }();
            // IERC20(weth).transfer(to, amount);
        }
    }

    /**
     * @notice Transfer ETH and return the success status.
     * @dev This function only forwards 30,000 gas to the callee.
     */
    function _safeTransferETH(
        address to,
        uint256 value
    ) internal returns (bool) {
        (bool success, ) = to.call{value: value, gas: 30_000}(new bytes(0));
        return success;
    }

    // uint256 firstTokenId;
    //     uint256 lastTokenId;
    //     uint256 startTime;
    //     uint256 endTime;
    //     DoubleLinkedLibrary.DList BiderList;
    //     bool settled;
}
