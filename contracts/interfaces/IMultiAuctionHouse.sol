// SPDX-License-Identifier: GPL-3.0

/// @title Interface for Noun Auction Houses

/*********************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░██░░░████░░██░░░████░░░ *
 * ░░██████░░░████████░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *********************************/

pragma solidity ^0.8.6;

interface IMultiAuctionHouse {
    struct MAuction {
        uint256 firstTokenId;
        uint256 lastTokenId;
        uint256 startTime;
        uint256 endTime;
        bool settled;
    }

    event MultiAuctionCreated(
        uint256 indexed firstTokenId,
        uint256 lastTokenId,
        uint256 startTime,
        uint256 endTime
    );

    event AuctionBid(
        uint256 indexed nounId,
        address sender,
        uint256 value,
        uint256 auctionNumber,
        bool extended
    );

    event AuctionExtended(uint256 indexed auctionNumber, uint256 endTime);

    event AuctionSettled(
        uint256 indexed nounId,
        address winner,
        uint256 amount
    );

    event AuctionTimeBufferUpdated(uint256 timeBuffer);

    event AuctionTurnDurationUpdated(uint256 turnDuration);

    event AuctionReservePriceUpdated(uint256 reservePrice);

    event AuctionMinBidIncrementPercentageUpdated(
        uint256 minBidIncrementPercentage
    );

    // function settleAuction() external;

    // function settleCurrentAndCreateNewAuction() external;

    // function createBid(uint256 nounId) external payable;

    // function pause() external;

    // function unpause() external;

    function setTimeBuffer(uint256 timeBuffer) external;

    function setTurnDuration(uint256 trunDuration) external;

    function setReservePrice(uint256 reservePrice) external;

    function setMinBidIncrementPercentage(
        uint8 minBidIncrementPercentage
    ) external;
}
