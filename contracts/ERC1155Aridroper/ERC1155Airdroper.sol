//SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC1155Airdroper is Ownable {

    constructor() Ownable(msg.sender) {}

    IERC1155 public token;
    uint256 public amount; 
    address public treasury;

    bool public initialized;

    error AlreadyInitialized();
    error ArraysLengthMismatch();
    error NotEnoughApprovedTokens();
    error TranfserFailed();
    error NotApproved();

    modifier notInitialized() {
        require (!initialized, AlreadyInitialized());
        _;
    }
    

    function initialize(bytes memory _initData) external notInitialized returns (bool) {

        (address _token, address _treasury, address _owner) = abi.decode(_initData, (address, address, address));

        token = IERC1155(_token);
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    function airdrop(address[] calldata receivers, uint256[] calldata amounts, uint256[] calldata tokenId) external onlyOwner {
        require(receivers.length == amounts.length && receivers.length == tokenId.length, ArraysLengthMismatch());
        require(token.isApprovedForAll(treasury, address(this)), NotApproved());


        for (uint256 i = 0; i < receivers.length; i++) {
            token.safeTransferFrom(treasury, receivers[i], tokenId[i], amounts[i], "");
        }

    }


    function getInitData(address _token, address _treasury, address _owner) external pure returns (bytes memory){
        return abi.encode(_token, _treasury, _owner);
    }

}
