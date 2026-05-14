// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../IUtilityContract.sol";

contract NFTAirdroper is IUtilityContract, Ownable {

    constructor() Ownable(msg.sender) {}

    ERC721 public token;
    address public treasury;
    bool private initialized;

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

        (address _token, address _treasury, address _owner) = abi.decode(_initData, (address, address, address));
        token = ERC721(_token);
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }



    function airdrop (address[] calldata _receivers, uint256[] calldata _tokenId) external {
        require(_receivers.length == _tokenId.length, LengthNotEqual());
        require(token.isApprovedForAll(treasury, address(this)), NotApproved());

        for (uint256 i = 0; i < _tokenId.length; i++) {
            token.safeTransferFrom(treasury, _receivers[i], _tokenId[i]);
        }        

        emit AirdroppedSuccessfull();
    }



    function getInitData(address _token, address _treasury, address _owner) external pure returns (bytes memory){
        return abi.encode(_token, _treasury, _owner);
    }

}