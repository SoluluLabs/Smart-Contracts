// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {StringsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import {SafeMathUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract SoluluReward is Initializable, OwnableUpgradeable {
    using StringsUpgradeable for uint256;
    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) public reward;
    mapping(address => bool) public isApprovedTokenAddress;

    address public treasury;

    address public soluluTokenAddress;

    event RewardUpdated(address indexed _address, uint256 _value);

    event RewardClaimed(address indexed _address, uint256 _value);

    event Deposited(address indexed _tokenAddress, address indexed _address, uint256 _value);

    event Withdraw(address indexed _tokenAddress, address indexed _address, uint256 _value);

    event TreasuryUpdated(address indexed _address);

    event TokenAddressUpdated(address indexed _address);

    event TokenAddressApproved(address indexed _address, bool _value);

    event WithdrawETH(address indexed _address, uint256 _value);



    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _tokenAddress, address _treasury) public initializer {
        __Ownable_init();
        soluluTokenAddress = _tokenAddress;
        treasury = payable(_treasury);
    }

    /**
     * @notice Deposit ERC20 token to the contract
     * @param _tokenAddress erc20 token address
     * @param _amount amount of token to deposit
     */
    function deposit(address _tokenAddress, uint256 _amount) external {
        require(isApprovedTokenAddress[_tokenAddress], "Token is not approved");
        if (_amount > 0) {
            IERC20(_tokenAddress).transferFrom(
                msg.sender,
                address(this),
                _amount
            );
        }
        emit Deposited(_tokenAddress, msg.sender, _amount);  
    }

    /**
     * @notice setApprovedTokenAddresses
     * @param _tokenAddresses List of token addresses
     * @param _values List of boolean values to set for each token address
     */
    function setApprovedTokenAddresses(address[] memory _tokenAddresses, bool[] memory _values) external onlyOwner {
        require(_tokenAddresses.length == _values.length, "Arrays length mismatch");
        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            isApprovedTokenAddress[_tokenAddresses[i]] = _values[i];
            emit TokenAddressApproved(_tokenAddresses[i], _values[i]);
        }
    }

    /**
     * @notice setSoluluTokenAddress
     * @param _tokenAddress Address of solulu token
     */
    function setTokenAddress(address _tokenAddress) external onlyOwner {
        soluluTokenAddress = _tokenAddress;
        emit TokenAddressUpdated(_tokenAddress);
    }

    /**
     * @notice claim reward
     * @param _amount Amount of reward to claim
     */
    function claimReward(uint256 _amount) external {
        require(_amount>=10 * 1 ether, "Requested withdrawal amount is less than 10");
        require(reward[msg.sender]>=_amount, "Requested withdrawal amount is less than reward balance");
        IERC20(soluluTokenAddress).transfer(msg.sender, _amount);
        reward[msg.sender] -= _amount;
        emit RewardClaimed(msg.sender, _amount);
    }

    /**
     * @notice withdraw ERC20 token from the contract
     * @param _tokenAddress erc20 token address
     * @param _amount amount of token to withdraw
     */
    function withdraw(address _tokenAddress, uint256 _amount) external onlyOwner {
        IERC20(_tokenAddress).transfer(treasury, _amount);
        emit Withdraw(_tokenAddress, treasury, _amount);
    }

    /**
     * @notice setTreasury
     * @param _treasury Address of treasury
     */
    function setTreasury(address _treasury) external onlyOwner {
        treasury = payable(_treasury);
        emit TreasuryUpdated(_treasury);
    }

    /**
     * @notice withdraw ETH from the contract
     * @dev Only owner can call this function
     */
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        (bool success, ) = treasury.call{value: balance}("");
        require(success, "Unable to withdraw ETH");
        emit WithdrawETH(treasury, balance);
    }

    /**
     * @notice update reward
     * @param _addresses List of addresses
     * @param values List of reward values to set for each address
     */
    function updateReward(address[] memory _addresses, uint256[] memory values) external onlyOwner {
        require(_addresses.length == values.length, "Arrays length mismatch");
        for (uint256 i = 0; i < _addresses.length; i++) {
            reward[_addresses[i]] += values[i] * 1 ether;
            emit RewardUpdated(_addresses[i], values[i]);
        }
    }
}
