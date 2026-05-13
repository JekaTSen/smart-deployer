//SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IERC20Airdroper {
    function initialize(bytes memory _initData) external returns (bool);
}