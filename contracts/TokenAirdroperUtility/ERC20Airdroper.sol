//SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IERC20Airdroper.sol";

contract ERC20Airdroper is IERC20Airdroper {

    IERC20 public token;
    uint256 public amount; //100 000

    bool public initialized;

    /*
    constructor(address _tokenAddress, uint256 _airdropAmount) {
        amount = _airdropAmount;
        token = IERC20(_tokenAddress);
    } */

    error AlreadyInitialized();

    modifier notInitialized() {
        require (!initialized, AlreadyInitialized());
        _;
    }
    

    function initialize(bytes memory _initData) external notInitialized returns (bool) {

        (address _tokenAddress, uint256 _airdropAmount) = abi.decode(_initData, (address, uint256));

        token = IERC20(_tokenAddress);
        amount = _airdropAmount;

        initialized = true;
        return true;
    }

    //------------------SmartContract functions---------------------------------------

    function airdrop(address[] calldata receivers, uint256[] calldata amounts) external {
        require(receivers.length == amounts.length, "arrays length mismatch");
        require(token.allowance(msg.sender, address(this)) >= amount, "not enought approved tokens");

        for (uint256 i = 0; i < receivers.length; i++) {
            require(token.transferFrom(msg.sender, receivers[i], amounts[i]), "transfer failed");
        }

    }

}