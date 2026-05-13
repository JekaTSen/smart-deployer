// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./INFTAirdroper.sol";

contract NFTAirdroper is INFTAirdroper {

    ERC721 public NFT;
    uint256 public amount; 
    bool private initialized;

    /*constructor (address _nftAddress, uint256 _amount) {
        NFT = ERC721(_nftAddress);
        amount = _amount;
    }*/

    event AirdroppedSuccessfull();

    error NotApproved();
    error NotOwnerOfNFT();
    error LengthNotEqual();
    error AlreadyInitialized();

    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }


    function initialize(bytes memory _initData) external notInitialized returns (bool) {

        (address _nftAddress, uint256 _amount) = abi.decode(_initData, (address, uint256));
        NFT = ERC721(_nftAddress);
        amount = _amount;

        initialized = true;
        return true;
    }

    //------------------SmartContract functions---------------------------------------

    function airdrop (address[] calldata _receivers, uint256[] calldata _idNFTs) external {
        require(_receivers.length == _idNFTs.length, LengthNotEqual());
        require(ERC721(NFT).isApprovedForAll(msg.sender, address(this)), NotApproved());

        for (uint256 i = 0; i < amount; i++) {
            require(ERC721(NFT).ownerOf(_idNFTs[i]) == msg.sender, NotOwnerOfNFT());
            NFT.safeTransferFrom(msg.sender, _receivers[i], _idNFTs[i]);
        }        
        emit AirdroppedSuccessfull();
    }

}