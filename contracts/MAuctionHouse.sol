// SPDX-License-Identifier: MIT
// Double Linked List
// Created by sciNFTist.eth
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IMToken.sol";

import "./interfaces/IMultiAuctionHouse.sol";
// import "OpenZeppelin/openzeppelin-contracts@4.8.0/contracts/utils/Checkpoints.sol";

import {DoubleLinkedLibrary} from "./library/DoubleLinkedLibrary.sol"; //DoubleLinkedLibrary.sol

pragma solidity ^0.8.0;

contract MultiAuctionHouse is IMultiAuctionHouse, Ownable {
    using DoubleLinkedLibrary for DoubleLinkedLibrary.DList;

    IMToken public MToken;

    uint256 private numberOfItemInAuction;

    // mapping(uint256 => DoubleLinkedLibrary.DList) private DLMap;
    //maybe insert number of token instead of firstTokenId and LastTokenID ~ justBalanceOf()
    //if they diidnt claim in claim
    // struct MAuction {
    //     uint256 firstTokenId;
    //     uint256 lastTokenId;
    //     uint256 startTime;
    //     uint256 endTime;
    //     bool settled;
    // }
    mapping(uint256 => DoubleLinkedLibrary.DList)
        private biddersInAuctionNumber;
    mapping(uint256 => MAuction) private mAuctions;

    uint256 public latestAuctionNumber;

    uint256 public timeBuffer;
    uint256 public reservePrice;
    uint256 public duration = 300;
    uint256 public turnDuration = 60;
    uint8 public minBidIncrementPercentage = 2;
    bool public initialized = false;

    /**
     * @notice Initialize the auction house and base contracts,
     * populate configuration values, and pause the contract.
     * @dev This function can only be called once.
     */
    function initialize(
        IMToken _MToken,
        uint256 _numberOfItem,
        uint256 _timeBuffer,
        uint256 _reservePrice,
        uint8 _minBidIncrementPercentage,
        uint256 _duration
    ) external {
        require(!initialized, "already initialized");
        // __Pausable_init();
        // __ReentrancyGuard_init();
        // __Ownable_init();
        require(
            _MToken.owner() == address(this),
            "Init with bad Owner, transfer ownership to this contract"
        );
        require(_numberOfItem > 0, "numberOfItem in auctin Should be non zero");
        numberOfItemInAuction = _numberOfItem;
        MToken = _MToken;
        // weth = _weth;
        timeBuffer = _timeBuffer;
        reservePrice = _reservePrice;
        minBidIncrementPercentage = _minBidIncrementPercentage;
        duration = _duration;
        // uint256 startTime = block.timestamp;
        // uint256 endTime = startTime + duration * 2;
        // uint256 firstToken = MToken.nextTokenId();
        // uint256 lastToken = firstToken + numberOfItemInAuction - 1;
        _createAuction();
        // uint256 lastToken = MToken.balanceOf(address(this)) -1;

        // bidderListInit();
        // mAuctions[auctionNumber] = MAuction({
        //     firstTokenId: firstToken,
        //     lastTokenId: lastToken,
        //     startTime: startTime,
        //     endTime: endTime,
        //     settled: false
        // });
        // // biddersInAuctionNumber[auctionNumber] = DoubleLinkedLibrary.DList;

        // // _pause();

        // // nouns = _nouns;
        // // weth = _weth;
        // // timeBuffer = _timeBuffer;
        // // reservePrice = _reservePrice;
        // // minBidIncrementPercentage = _minBidIncrementPercentage;
        // // duration = _duration;

        // initialized = true;
    }

    //--------------------BidderList Init-----------

    function bidderListInit() private {
        latestAuctionNumber++;

        biddersInAuctionNumber[latestAuctionNumber].initDLL();
    }

    //------------ BidderList view
    function getCounter(uint256 _auctionNumber) public view returns (uint256) {
        return biddersInAuctionNumber[_auctionNumber].getCounterDLL();
    }

    function getData(
        uint256 _auctionNumber,
        uint256 pos
    ) public view returns (uint256) {
        return biddersInAuctionNumber[_auctionNumber].getDataDLL(pos);
    }

    function getBidder(
        uint256 _auctionNumber,
        uint256 pos
    ) public view returns (address) {
        return biddersInAuctionNumber[_auctionNumber].getBidderDLL(pos);
    }

    function getIndex(
        uint256 _auctionNumber,
        uint256 pos
    ) public view returns (uint256) {
        return biddersInAuctionNumber[_auctionNumber].getIndexDLL(pos);
    }

    function getPrev(
        uint256 _auctionNumber,
        uint256 pos
    ) public view returns (uint256) {
        return biddersInAuctionNumber[_auctionNumber].getPrevDLL(pos);
    }

    function getNext(
        uint256 _auctionNumber,
        uint256 pos
    ) public view returns (uint256) {
        return biddersInAuctionNumber[_auctionNumber].getNextDLL(pos);
    }

    function getLen(uint256 _auctionNumber) public view returns (uint256) {
        return biddersInAuctionNumber[_auctionNumber].getLenDLL();
    }

    function getHead(uint256 _auctionNumber) public view returns (uint256) {
        return biddersInAuctionNumber[_auctionNumber].getHeadDLL();
    }

    function getTail(uint256 _auctionNumber) public view returns (uint256) {
        return biddersInAuctionNumber[_auctionNumber].getTailDLL();
    }

    function getCurrentAuctionNumber() public view returns (uint256) {
        return latestAuctionNumber;
    }

    //
    function posValidator(
        uint256 _auctionNumber,
        uint256 _pos,
        uint256 data
    ) public view returns (bool) {
        return
            biddersInAuctionNumber[_auctionNumber].posValidatorDLL(_pos, data);
    }

    function findPos(
        uint256 _auctionNumber,
        uint256 data
    ) public view returns (uint256) {
        return biddersInAuctionNumber[_auctionNumber].findPosDLL(data);
    }

    function removeThis(uint256 _auctionNumber, uint256 _pos) internal {
        biddersInAuctionNumber[_auctionNumber].removeThisDLL(_pos);
    }

    function setSort(
        uint256 _auctionNumber,
        uint256 _pos,
        uint256 data
    ) public {
        biddersInAuctionNumber[_auctionNumber].setSortDLL(
            _pos,
            data,
            msg.sender
        );
    }

    function numberOfItem(
        uint256 _auctionNumber
    ) public view returns (uint256) {
        return
            (mAuctions[_auctionNumber].lastTokenId -
                mAuctions[_auctionNumber].firstTokenId) + 1;
    }

    function isBidable(
        uint256 auctionNumber,
        uint256 val
    ) public view returns (bool) {
        if (val < reservePrice) {
            return false;
        }

        if (getLen(auctionNumber) < numberOfItem(auctionNumber)) {
            return true;
        } else {
            uint256 tailPointer = getTail(auctionNumber);
            uint256 tailValue = getData(auctionNumber, tailPointer);
            // address tailAddress = getBidder(tailPointer);
            if (
                val >
                tailValue + ((tailValue * minBidIncrementPercentage) / 100)
            ) {
                return true;
            }
        }
        return false;
    }

    ///----------Auction status
    //  MAuction({
    //         firstTokenId: firstToken,
    //         lastTokenId: lastToken,
    //         startTime: startTime,
    //         endTime: endTime,
    //         settled: false
    //     });
    function getStartTime(
        uint256 _auctionNumber
    ) public view returns (uint256) {
        return mAuctions[_auctionNumber].startTime;
    }

    function getEndTime(uint256 _auctionNumber) public view returns (uint256) {
        return mAuctions[_auctionNumber].endTime;
    }

    function getSettled(uint256 _auctionNumber) public view returns (bool) {
        return mAuctions[_auctionNumber].settled;
    }

    ///---------finish--------
    function finishIt(uint256 _auctionNumber) public {
        require(
            !biddersInAuctionNumber[_auctionNumber].isFinishedDLL(),
            "finishing err0"
        );
        biddersInAuctionNumber[_auctionNumber].finishDLL();
        // biddersInAuctionNumber[auctionNumber].index0(
        //     biddersInAuctionNumber[auctionNumber].getTail(auctionNumber)
        // );
    }

    // function getToken(uint256 tokenId, uint256 _pos, uint256 _auctionNumber) public {
    function getToken(
        uint256 _auctionNumber,
        uint256 tokenId,
        uint256 _pos
    ) public {
        //getAuction
        // require(tokenId <=lastTokenId)
        uint256 _index;
        MAuction memory _mauction = mAuctions[_auctionNumber];

        _index = getIndex(_auctionNumber, _pos);
        if (_index == 0) {
            biddersInAuctionNumber[_auctionNumber].index0DLL(_pos);
        }
        _index = getIndex(_auctionNumber, _pos);
        require(_index > 0, "remove it ");
        require(
            msg.sender ==
                biddersInAuctionNumber[_auctionNumber].getBidderDLL(_pos),
            "you are not the owner of the bid"
        );

        // require(block.timestamp > _mauction.endTime + _index * turnDuration);
        require(tokenId <= _mauction.lastTokenId);
        require(tokenId >= _mauction.firstTokenId);
        require(
            MToken.ownerOf(tokenId) == address(this),
            "this token has been transfered or not existed"
        );
        MToken.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    /**
     * @notice Settle an auction, finalizing the bid and paying out to the owner.
     * @dev If there are no bids, the Noun is burned.
     */
    // function _settleAuction(uint256 _pos) internal {
    //     IMultiAuctionHouse.MAuction memory _auction = Mauction;

    //     require(_auction.startTime != 0, "Auction hasn't begun");
    //     require(!_auction.settled, "Auction has already been settled");
    //     require(
    //         block.timestamp >= _auction.endTime,
    //         "Auction hasn't completed"
    //     );

    //     auction.settled = true;

    //     if (_auction.bidder == address(0)) {
    //         nouns.burn(_auction.nounId);
    //     } else {
    //         nouns.transferFrom(address(this), _auction.bidder, _auction.nounId);
    //     }

    //     if (_auction.amount > 0) {
    //         _safeTransferETHWithFallback(owner(), _auction.amount);
    //     }

    //     emit AuctionSettled(_auction.nounId, _auction.bidder, _auction.amount);
    // }

    /**
     * @notice Set the auction time buffer.
     * @dev Only callable by the owner.
     */
    function setTimeBuffer(uint256 _timeBuffer) external override onlyOwner {
        timeBuffer = _timeBuffer;

        emit AuctionTimeBufferUpdated(_timeBuffer);
    }

    /**
     * @notice Set the turn Duration.
     * @dev Only callable by the owner.
     */
    function setTurnDuration(
        uint256 _turnDuration
    ) external override onlyOwner {
        turnDuration = _turnDuration;

        emit AuctionTurnDurationUpdated(_turnDuration);
    }

    /**
     * @notice Set the auction reserve price.
     * @dev Only callable by the owner.
     */
    function setReservePrice(
        uint256 _reservePrice
    ) external override onlyOwner {
        reservePrice = _reservePrice;

        emit AuctionReservePriceUpdated(_reservePrice);
    }

    /**
     * @notice Set the auction minimum bid increment percentage.
     * @dev Only callable by the owner.
     */
    function setMinBidIncrementPercentage(
        uint8 _minBidIncrementPercentage
    ) external override onlyOwner {
        minBidIncrementPercentage = _minBidIncrementPercentage;

        emit AuctionMinBidIncrementPercentageUpdated(
            _minBidIncrementPercentage
        );
    }

    // if end?

    /////////////Bidding

    function createBid(uint256 auctionNumber, uint256 pos) external payable {
        // INounsAuctionHouse.Auction memory _auction = auction;

        require(
            block.timestamp < mAuctions[auctionNumber].endTime,
            "Auction expired"
        );
        require(msg.value >= reservePrice, "Must send at least reservePrice");
        //------
        if (getLen(auctionNumber) < numberOfItem(auctionNumber)) {
            setSort(auctionNumber, pos, msg.value);
            // whiteListed[msg.sender];
            // emit val(msg.value);
        } else {
            uint256 tailPointer = getTail(auctionNumber);
            uint256 tailValue = getData(auctionNumber, tailPointer);
            address tailAddress = getBidder(auctionNumber, tailPointer);
            // require(msg.value >= tailValue, "?!?");
            require(
                msg.value >
                    tailValue + ((tailValue * minBidIncrementPercentage) / 100),
                "Must send more than last bid by minBidIncrementPercentage amount"
            );
            // emit val(msg.value);
            // emit val(tailValue);

            setSort(auctionNumber, pos, msg.value);
            removeThis(auctionNumber, tailPointer);
            _safeTransferETHWithFallback(tailAddress, tailValue);
        }
    }

    ///--------settle make the -- make list immutable -- indexing calim --

    function _createAuction() internal {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + duration;
        uint256 _nextTokenId = MToken.nextTokenId();
        MToken.mintBatch(address(this), numberOfItemInAuction);
        bidderListInit();
        mAuctions[latestAuctionNumber] = MAuction({
            firstTokenId: _nextTokenId,
            lastTokenId: _nextTokenId + numberOfItemInAuction - 1,
            startTime: startTime,
            endTime: endTime,
            settled: false
        });
        // biddersInAuctionNumber[auctionNumber] = DoubleLinkedLibrary.DList;
        emit MultiAuctionCreated(
            _nextTokenId,
            _nextTokenId + numberOfItemInAuction - 1,
            startTime,
            endTime
        );
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
