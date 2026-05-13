//SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC20Airdroper.sol";

contract ERC20Airdroper is IERC20Airdroper, Ownable {

    constructor() Ownable(msg.sender) {}

    IERC20 public token;
    uint256 public amount; 
    address public treasury;

    bool public initialized;

    error AlreadyInitialized();
    error ArraysLengthMismatch();
    error NotEnoughApprovedTokens();
    error TranfserFailed();

    modifier notInitialized() {
        require (!initialized, AlreadyInitialized());
        _;
    }
    

    function initialize(bytes memory _initData) external notInitialized returns (bool) {

        (address _token, uint256 _amount, address _treasury, address _owner) = abi.decode(_initData, (address, uint256, address, address));

        token = IERC20(_token);
        amount = _amount;
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    //------------------SmartContract functions---------------------------------------

    function airdrop(address[] calldata receivers, uint256[] calldata amounts) external onlyOwner {
        require(receivers.length == amounts.length, ArraysLengthMismatch());
        require(token.allowance(treasury, address(this)) >= amount, NotEnoughApprovedTokens());

        for (uint256 i = 0; i < receivers.length; i++) {
            require(token.transferFrom(treasury, receivers[i], amounts[i]), TranfserFailed());
        }

    }

    


    function getInitData(address _token, uint256 _amount, address _treasury, address _owner) external pure returns (bytes memory){
        return abi.encode(_token, _amount, _treasury, _owner);
    }

}

/* just for test --> getInitData() --> initialize on ERC20Airdroper.sol
0x3643b7a9F6338115159a4D3a2cc678C99aD657aa
10000000000000000000000
0xdD870fA1b7C4700F2BD7f44238821C26f7392148
0x5B38Da6a701c568545dCfcB03FcB875f56beddC4


0x0000000000000000000000003643b7a9f6338115159a4d3a2cc678c99ad657aa00000000000000000000000000000000000000000000021e19e0c9bab2400000000000000000000000000000dd870fa1b7c4700f2bd7f44238821c26f73921480000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4
*/



/*
["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db", "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB", "0x617F2E2fD72FD9D5503197092aC168c91465E7f2"]
[3000000000000000000000, 3000000000000000000000, 2000000000000000000000, 2000000000000000000000]

*/