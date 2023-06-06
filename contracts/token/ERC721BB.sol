// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IERC2309.sol";

abstract contract ERC721BB is ERC721, IERC2309 {
    /**
     *@dev my proposal
     */
    //maxSupply
    uint256 private _nextTokenId;
    //NFT owner
    // address private immutable _preOwner;
    struct OwnerRange {
        address batchOwner;
        uint96 lastToken;
    }
    OwnerRange[] private ownersRange;

    function nextTokenId() public view returns (uint256) {
        return _nextTokenId;
    }

    /**@dev my proposal
     * i
     *for values greater equal than maxSupply, ownerOf(tokenId) will alweys return zero address 0x0 i.e address(0). therefor token _exist() is false for these values.
     * for values smaller than maxSupply, if _owners[tokenId] is not address 0 the owner is the returned value.
     *If the _owners[tokenId] is the defualt value 0x0 (i.e address(0) )  & the tokenId is smaller than maxSupply it returns preOwner.
     */
    function _mintBatch(address _to, uint256 _ammount) internal {
        require(_ammount <= 5000, "max batch is 5000");
        require(_ammount > 0, "zero amount is not acceptable");
        // _balances[_to] += _ammount;
        __unsafe_increaseBalance(_to, _ammount);
        _nextTokenId += _ammount;
        uint256 len = ownersRange.length;
        if (len > 0 && ownersRange[len - 1].batchOwner == _to) {
            ownersRange[len - 1].lastToken += uint96(_ammount);
        } else {
            ownersRange.push(
                OwnerRange(_to, uint96(_nextTokenId + _ammount - 1))
            );
        }
        emit ConsecutiveTransfer(
            _nextTokenId,
            _nextTokenId + _ammount - 1,
            address(0),
            _to
        );
    }

    function _ownerOf(
        uint256 tokenId
    ) internal view virtual override returns (address) {
        // address owner = _owners[tokenId];
        address owner = super._ownerOf(tokenId); //_owners[tokenId];
        if (owner == address(0) && (tokenId < _nextTokenId)) {
            return _batchOwner(tokenId);
        }
        return owner;
    }

    function _batchOwner(uint256 tokenId) internal view returns (address) {
        uint256 len = ownersRange.length;
        if (tokenId >= _nextTokenId) return address(0);

        for (uint256 i = 1; i <= len; i++) {
            if (ownersRange[len - i].lastToken >= tokenId) {
                return ownersRange[len - i].batchOwner;
            }
        }
        return address(0);
    }
}
