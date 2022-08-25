// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
//import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

/**
* @title Passport fot network City
* @dev non-transferable, burnable ERC721 use as passport for the City
 */
contract Passport is ERC721, ERC721Enumerable,Pausable, AccessControl,  ERC721Burnable 
{
    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BASEURI_SETTER_ROLE = keccak256("BASEURI_SETTER_ROLE");
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;
    address private _owner;

    uint256 public numberOfPassport;

    event NewNFTPassort(address _adress,uint256 passportId);

    // Mapping of owners of passport
    mapping(address => uint256) private ownerByTokenId;

    // Mapping of tokenIds to the owner of the passport
    mapping(uint256 => address) private adressByTokenid;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("MdOr", "MDO") {
        _owner = msg.sender;
        numberOfPassport = 0;

        /*
        ,EIP712 
        __EIP712_init("MdOr", "1");
        ,ERC721Votes
        __ERC721Votes_init();
        */

        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(PAUSER_ROLE, _owner);
        _grantRole(MINTER_ROLE, msg.sender);
    }
    /**
    * @dev DANGER Gas Cost, use if really needed on mainnet
     */
    function getPassportList() public view onlyRole(DEFAULT_ADMIN_ROLE) returns (address[] memory){
        
    }
    
    
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }
    //onlyRole(DEFAULT_ADMIN_ROLE) !!!!!
    function createPassport(address citizenadress) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused returns (uint256)
    {
        require(
            balanceOf(citizenadress)< 1, "This adress as alredy a passport for this city"
        );
        uint256 newpassportId = _tokenIds.current();
        safeMint(citizenadress, newpassportId);
        //_setTokenURI(newpassportId, tokenURI_);
        ownerByTokenId[citizenadress]= newpassportId;
        adressByTokenid[newpassportId] = citizenadress;

        _tokenIds.increment();
        emit NewNFTPassort(citizenadress, newpassportId);
        return newpassportId;
    }
    function revokePassport(uint256 tokenId) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused returns (uint256 _tokenId)
    {
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "NonTransferrableERC721Token: account does not have minter role"
        );
        
        _burn(tokenId);
        address tokenOwnerAdress = adressByTokenid[tokenId];
        delete ownerByTokenId[tokenOwnerAdress];
        delete adressByTokenid[tokenId];
        return tokenId;
    }
    function safeMint(address to, uint256 tokenId) internal  {
        _safeMint(to, tokenId);
        _approve(msg.sender, tokenId);
        numberOfPassport++;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        /** 
        * @dev non-transferable, burnable ERC721
        */
        require(from == address(0) || to == address(0), "NonTransferrableERC721Token: non transferrable");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.
/*
    function _afterTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Votes)
    {
        super._afterTokenTransfer(from, to, tokenId);
    }
*/
    function _burn(uint256 tokenId) internal override (ERC721) onlyRole(MINTER_ROLE) {
        super._burn(tokenId);
        numberOfPassport--;
    }

    /*function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    */

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable,AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
        
}