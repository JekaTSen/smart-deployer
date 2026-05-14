// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../IUtilityContract.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vesting is IUtilityContract, Ownable {

    constructor() Ownable (msg.sender) {}

    IERC20 public token;
    uint256 public totalAmount;
    
    address public beneficiary; 
    //mapping(address => uint256) public beneficiaries; //3. Vesting smart contract can be used by multiple people.  MerkleTree or Mapping (both is good)


    uint256 public startTime;
    uint256 public cliff;
    uint256 public duration;

    uint256 public claimed;
    uint256 public cooldown;

    bool public vestingStarted;

    bool public initialized;



    error AlreadyInitialized();
    error ClaimerIsNotBeneficiary();
    error CliffNotReached();
    error NothingToClaim();
    error TranfserFailed();
    error Cooldown();
    error MinClaimAmount();
    error NotEnoughTokensOnContract();
    error vestingWasntStartedYet();

    event Claimed(address beneficiary, uint256 amount, uint256 timestamp);
    event VestingStarted(uint256 timestamp);

    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }
    



    function startVesting(uint256 _cliff, uint256 _duration) external onlyOwner {
        require(token.balanceOf(address(this)) >= totalAmount, NotEnoughTokensOnContract());
        
        cliff = _cliff;
        duration = _duration;
        startTime = block.timestamp;

        //return true;
        vestingStarted = true;

        emit VestingStarted(block.timestamp);
    }


    function claim() public {
        require(vestingStarted, vestingWasntStartedYet());
        require(block.timestamp > startTime + cliff, CliffNotReached());
        require(cooldown < block.timestamp, Cooldown()); //cooldown if u claimed, have to wait 1 day
        require(msg.sender == beneficiary, ClaimerIsNotBeneficiary());

        uint256 claimable = claimableAmount();
        require(claimable > 0, NothingToClaim());
        require(claimable > 100, MinClaimAmount()); //min 100

        claimed += claimable;
        (bool success) = token.transfer(beneficiary, claimable);
        require(success, TranfserFailed());

        cooldown = block.timestamp + 1 days;
        emit Claimed(msg.sender, claimable, block.timestamp);
    }


    function vestedAmount() public view returns (uint256) {
        if(block.timestamp < startTime + cliff) return 0;

        uint256 passedTime = block.timestamp - (startTime + cliff);
        return (totalAmount * passedTime) / duration;
    }


    function claimableAmount() public view returns (uint256) { 
        if(block.timestamp < startTime + cliff) return 0;
        
        return vestedAmount() - claimed;
    }



    function initialize(bytes memory _initData) external notInitialized returns (bool) {

        (address _token, uint256 _totalAmount, address _owner) = abi.decode(_initData, (address, uint256, address));

        token = IERC20(_token);
        totalAmount = _totalAmount;
        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }


    function getInitData(address _token, uint256 _totalAmount, address _owner) external pure returns (bytes memory){
        return abi.encode(_token, _totalAmount, _owner);
    }



}