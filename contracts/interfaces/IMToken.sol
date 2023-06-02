// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IMToken is IERC721 {
    function mintBatch(address to, uint256 ammount) external;

    function owner() external view returns (address);

    function nextTokenId() external view returns (uint256);
}
