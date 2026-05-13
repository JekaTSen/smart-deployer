// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./IUtilityContract.sol";

contract DeployManager is Ownable {
    event NewContractAdded(
        address _contractAddress,
        uint256 _fee,
        bool _isActive,
        uint256 timestamp
    );
    event ContractFeeUpdated(
        address _contractAddress,
        uint256 _oldFee,
        uint256 _newFee,
        uint256 timestamp
    );
    event ContractStatusUpdated(
        address _contractAddress,
        bool isActive,
        uint256 timestamp
    );
    event NewDeployment(
        address _deployer,
        address _contractAddress,
        uint256 _fee,
        uint256 timestamp
    );

    error ContractNotActive();
    error NotEnoughFunds();
    error ContractDoesNotRegistered();
    error InitializationFailed();
    error ContractDoesNotRegistred();

    constructor() Ownable(msg.sender) {}

    struct ContractInfo {
        uint256 fee;
        bool isActive;
        uint256 registredAt;
    }

    mapping(address => address[]) public deployedContracts;
    mapping(address => ContractInfo) public contractsData;

    function deploy(
        address _utilityContract,
        bytes calldata _initData
    ) external payable returns (address) {
        ContractInfo memory info = contractsData[_utilityContract];

        require(info.isActive, ContractNotActive());
        require(msg.value >= info.fee, NotEnoughFunds());
        require(info.registredAt > 0, ContractDoesNotRegistered());

        //deploy new contract
        address clone = Clones.clone(_utilityContract);
        require(
            IUtilityContract(clone).initialize(_initData),
            InitializationFailed()
        ); //initialization

        payable(owner()).transfer(msg.value); //transfer money

        deployedContracts[msg.sender].push(clone); //updateInformation

        emit NewDeployment(msg.sender, clone, msg.value, block.timestamp);

        return clone;
    }

    function addNewContract(
        address _contractAddress,
        uint256 _fee,
        bool _isActive
    ) external onlyOwner {
        contractsData[_contractAddress] = ContractInfo({
            fee: _fee,
            isActive: _isActive,
            registredAt: block.timestamp
        });

        emit NewContractAdded(
            _contractAddress,
            _fee,
            _isActive,
            block.timestamp
        );
    }

    function updateFee(
        address _contractAddress,
        uint256 _newFee
    ) external onlyOwner {
        require(contractsData[_contractAddress].registredAt > 0, ContractDoesNotRegistred());
        uint256 _oldFee = contractsData[_contractAddress].fee;
        contractsData[_contractAddress].fee = _newFee;

        emit ContractFeeUpdated(
            _contractAddress,
            _oldFee,
            _newFee,
            block.timestamp
        );
    }

    function deactivate(address _address) external onlyOwner {
        require(contractsData[_address].registredAt > 0, ContractDoesNotRegistred());
        contractsData[_address].isActive = false;
        emit ContractStatusUpdated(_address, false, block.timestamp);
    }

    function activate(address _address) external onlyOwner {
        require(contractsData[_address].registredAt > 0, ContractDoesNotRegistred());
        contractsData[_address].isActive = true;
        emit ContractStatusUpdated(_address, true, block.timestamp);
    }
}
