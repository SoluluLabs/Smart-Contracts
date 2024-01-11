// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MerkleProofUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import {IERC2981Upgradeable, ERC2981Upgradeable} from "@openzeppelin/contracts-upgradeable/token/common/ERC2981Upgradeable.sol";
import {StringsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import {SafeMathUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import {OperatorFilterer} from "closedsea/src/OperatorFilterer.sol";
import {IERC721AUpgradeable, ERC721AUpgradeable} from "erc721a-upgradeable/contracts/ERC721AUpgradeable.sol";
import {ERC4907AUpgradeable} from "erc721a-upgradeable/contracts/extensions/ERC4907AUpgradeable.sol";
import {ERC721AQueryableUpgradeable} from "erc721a-upgradeable/contracts/extensions/ERC721AQueryableUpgradeable.sol";
import {ERC721ABurnableUpgradeable} from "erc721a-upgradeable/contracts/extensions/ERC721ABurnableUpgradeable.sol";
import {IERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
// import "./interfaces/IDelegationRegistry.sol";
// import "./interfaces/IChompiesV2.sol";

/**
 * @title Solulu.ai
 * @author @soluluai
 */
contract SoluluAI is
    ERC721AQueryableUpgradeable,
    ERC721ABurnableUpgradeable,
    ERC2981Upgradeable,
    ERC4907AUpgradeable,
    OperatorFilterer,
    OwnableUpgradeable
{
    using StringsUpgradeable for uint256;
    using SafeMathUpgradeable for uint256;

    /// @notice Base uri
    string public baseURI;

    /// @dev Treasury
    address public treasury;

    /// @notice Public mint
    bool public isPublicOpen;

    /// @notice ETH mint price
    uint256 public mintPrice;

    /// @notice Operator filter toggle switch
    bool private operatorFilteringEnabled;
    
    /// @notice kecids
    mapping (uint256 => bytes32) public kecId;


    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory baseURI_
    ) public initializer initializerERC721A {
        __ERC721A_init("Solulu AI", "SOLULUAI");
        __Ownable_init();
        __ERC2981_init();
        __ERC4907A_init();
        // Setup filter registry
        _registerForOperatorFiltering();
        operatorFilteringEnabled = true;
        // Setup royalties to 7% (default denominator is 10000)
        _setDefaultRoyalty(_msgSender(), 700);
        // Set metadata
        baseURI = baseURI_;
        // Set treasury
        treasury = payable(_msgSender());

        isPublicOpen = false;

    }



    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }


    function mint(
        uint96 royaltyPercentage, string memory characterId
    ) external payable  {
        require(isPublicOpen, "!open");
        require(msg.value >= 1 * mintPrice,"!not enough");
        require(royaltyPercentage <= 1000, "above max royalty");
        _processMint(1, royaltyPercentage, characterId);
    }

    function _processMint( uint256 _amount, uint96 royaltyPercentage, string memory characterId) internal {
        address sender = _msgSenderERC721A();
        uint256 tokenId = totalSupply()+1;
        if (royaltyPercentage > 0) {
            _setTokenRoyalty(tokenId, sender, royaltyPercentage);
        }
        bytes32 _kecId = keccak256(abi.encodePacked(sender, characterId));
        kecId[tokenId] = _kecId;
        _mint(sender, _amount);

    }

    function setApprovalForAll(
        address operator,
        bool approved
    )
        public
        override(IERC721AUpgradeable, ERC721AUpgradeable)
        onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    function approve(
        address operator,
        uint256 tokenId
    )
        public
        payable
        override(IERC721AUpgradeable, ERC721AUpgradeable)
        onlyAllowedOperatorApproval(operator)
    {
        
        super.approve(operator, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        public
        payable
        override(IERC721AUpgradeable, ERC721AUpgradeable)
        onlyAllowedOperator(from)
    {
        
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        public
        payable
        override(IERC721AUpgradeable, ERC721AUpgradeable)
        onlyAllowedOperator(from)
    {
        
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    )
        public
        payable
        override(IERC721AUpgradeable, ERC721AUpgradeable)
        onlyAllowedOperator(from)
    {
        
        super.safeTransferFrom(from, to, tokenId, data);
    }

    
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(
            IERC721AUpgradeable,
            ERC721AUpgradeable,
            ERC2981Upgradeable,
            ERC4907AUpgradeable
        )
        returns (bool)
    {
        return
            ERC721AUpgradeable.supportsInterface(interfaceId) ||
            ERC2981Upgradeable.supportsInterface(interfaceId) ||
            ERC4907AUpgradeable.supportsInterface(interfaceId);
    }

    /**
     * @notice Token uri
     * @param tokenId The token id
     */
    function tokenURI(
        uint256 tokenId
    )
        public
        view
        virtual
        override(IERC721AUpgradeable, ERC721AUpgradeable)
        returns (string memory)
    {
        require(_exists(tokenId), "!exists");
        bytes32 tokenIdBytes = kecId[tokenId];
        string memory tokenIdString = string(abi.encodePacked(tokenIdBytes));
        return string(abi.encodePacked(baseURI, tokenIdString));
    }


    /**
     * @notice Sets public mint is open
     */
    function setIsPublicOpen() external onlyOwner {
        isPublicOpen = !isPublicOpen;
    }

    
    /**
     * @notice Sets mint price
     * @param _mintPrice The eth price in wei
     */
    function setPrices(
        uint256 _mintPrice
    ) external onlyOwner {
        mintPrice = _mintPrice;
    }

    /**
     * @notice Sets the treasury recipient
     * @param _treasury The treasury address
     */
    function setTreasury(address _treasury) public onlyOwner {
        treasury = payable(_treasury);
    }

    /**
     * @notice Sets the base uri for the token metadata
     * @param _baseURI The base uri
     */
    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    
    /**
     * @notice Set default royalty
     * @param receiver The royalty receiver address
     * @param feeNumerator A number for 10k basis
     */
    function setDefaultRoyalty(
        address receiver,
        uint96 feeNumerator
    ) external onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    /// @notice Withdraws ETH funds from contract
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = treasury.call{value: balance}("");
        require(success, "Unable to withdraw ETH");
    }

    
    /**
     * @dev Airdrop function
     * @param _to The addresses to mint to airdrop too
     */
    function airdrop(address[] calldata _to) external onlyOwner {
        for (uint256 i = 0; i < _to.length; ) {
            _mint(_to[i], 1);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Sets whether the operator filter is enabled or disabled
     */
    function setOperatorFilteringEnabled() public onlyOwner {
        operatorFilteringEnabled = !operatorFilteringEnabled;
    }

    function _operatorFilteringEnabled() internal view override returns (bool) {
        return operatorFilteringEnabled;
    }

    function _isPriorityOperator(
        address operator
    ) internal pure override returns (bool) {
        // OpenSea Seaport Conduit:
        // https://etherscan.io/address/0x1E0049783F008A0085193E00003D00cd54003c71
        return operator == address(0x1E0049783F008A0085193E00003D00cd54003c71);
    }

}