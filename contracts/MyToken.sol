// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./token/ERC721BA.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MyToken is ERC721BA, Ownable {
    using Strings for uint256;

    string private name_ = "FFR Project : ffff";
    string private symbol_ = "FPP";
    // uint256 private maxSupply_ = 150;
    // address private preOwner_ = 0x66aB6D9362d4F35596279692F0251Db635165871;

    //
    bool private notFinialized = true;

    constructor(
        address preOwner_,
        uint256 maxSupply_
    ) ERC721BA(name_, symbol_, maxSupply_, preOwner_) {}

    function singleMint() public {
        _mint(msg.sender);
    }
}
