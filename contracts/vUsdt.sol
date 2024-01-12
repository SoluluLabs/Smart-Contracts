// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.19;
import "./Ownable.sol";
import "./ERC20.sol";
import "./ERC20Burnable.sol";


contract VirtualUSDT is ERC20, ERC20Burnable, Ownable {

  mapping(address => bool) controllers;
  bool public publicmint;
  mapping(address => uint256) public lastMintTimestamp;
  uint256 public perMintLimit;
  
  constructor(string memory name, string memory symbol, uint256 mintLimit) ERC20(name, symbol) {
    controllers[msg.sender] = true;
    perMintLimit = mintLimit;
  }

  function mint() public {
    require(controllers[msg.sender] || publicmint, "Only controllers can mint while public mint is paused");
    require(block.timestamp >= lastMintTimestamp[msg.sender] + 30 days, "Cannot mint before 30 days from the last mint" );
    uint256 tokens = perMintLimit * 1 ether;
    _mint(msg.sender, tokens);
    lastMintTimestamp[msg.sender] = block.timestamp;
  }

  function setPerMintLimit(uint256 limit) external onlyOwner {
    perMintLimit = limit;
  }

  function MintByOwner(address to, uint256 amount) external onlyOwner {
    uint256 tokens = amount * 1 ether;
    _mint(to, tokens);
  }

  function multiDrop(address[] calldata accounts, uint256 _amount) public {
    require(controllers[msg.sender], "Only controllers can mint");
    uint256 tokens = _amount * 1 ether;
    for(uint i; i<accounts.length;i++) {
      _mint(accounts[i], tokens);
    }
  }

  function mintByController(address to, uint256 amount) public {
    require(controllers[msg.sender], "Only controllers can mint");
    uint256 tokens = amount * 1 ether;
    _mint(to, tokens);
  }

  function burnFrom(address account, uint256 amount) public override {
      if (controllers[msg.sender]) {
          _burn(account, amount);
      }
      else {
          super.burnFrom(account, amount);
      }
  }

  function useAllowance(address account, uint256 amount, address receiver) public {
  super.transferFrom(account,receiver,amount);
}

  function addController(address controller) public onlyOwner {
    controllers[controller] = true;
  }

  function removeController(address controller) external onlyOwner {
    controllers[controller] = false;
  }

function isPublicMint() external onlyOwner {
    publicmint = !publicmint;
  }
}