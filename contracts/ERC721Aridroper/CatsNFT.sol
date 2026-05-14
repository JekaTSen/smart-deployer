// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.6.0
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CatsNFT is ERC721, Ownable {
    uint256 private _nextTokenId;

    constructor(address initialOwner)
        ERC721("Cats", "cats")
        Ownable(initialOwner)
    {}

    function safeMint(address to) public onlyOwner returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        return tokenId;
    }

    function safeMintTenTimes(address to) public onlyOwner returns (uint256 [] memory) {
        uint256[] memory totMinted = new uint256[] (10); 

        for(uint256 i = 0; i < 10; i++) {
            totMinted[i] = safeMint(to);
        }

        return totMinted;
    }


}