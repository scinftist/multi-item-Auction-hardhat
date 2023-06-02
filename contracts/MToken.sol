// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./token/ERC721BA.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MToken is ERC721BA, Ownable {
    using Strings for uint256;

    string private name_ = "MAH Project : ffff";
    string private symbol_ = "MAH";
    // uint256 private maxSupply_ = 150;
    // address private preOwner_ = 0x66aB6D9362d4F35596279692F0251Db635165871;

    //
    bool private notFinialized = true;

    constructor() ERC721BA(name_, symbol_) {}

    // transferOwnerShip

    function mintBatch(address to, uint256 ammount) public onlyOwner {
        ERC721BA._mintBatch(to, ammount);
    }

    // function owner() public view virtual override returns (address) {
    //     return Ownable.owner();
    // }
}
