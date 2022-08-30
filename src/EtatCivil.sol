// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Pausable} from "openzeppelin-contracts/contracts/security/Pausable.sol";
import  {Counters} from "openzeppelin-contracts/contracts/utils/Counters.sol";
import  {Passport} from "./Passport.sol";


/**
* @title Registry for network City
* @dev Faucet for burnable ERC721 use as passport for the City
 */
contract EtatCivil is Pausable, Ownable 
{
    
    // Token name
    string public _name;
    // Token symbol
    string public _symbol;

    address private _owner;

    uint256 public numberOfPassport;

    // ERC721 Token
    Passport public passport;


    // Mapping of owners of passport
    mapping(address => uint256) private tokenIdByAddress ;

    // Mapping of tokenIds to the owner of the passport
    mapping(uint256 => address) private  adressByTokenid;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(string memory name, string memory symbol, address  owner_){
        _owner = owner_;
        numberOfPassport = 0;
        _name = name;
        _symbol = symbol;
        _tokenIds._value = 1234567;
        passport = new Passport(name,symbol,_owner);
      
    }
    
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
    

    function createPassport(address citizenadress) public onlyOwner whenNotPaused returns (uint256)
    {
        require(
            tokenIdByAddress[citizenadress] < 1, "ALREDYHAVEONE"
        );
        uint256 newpassportId = _tokenIds.current();
        passport.safeMint(citizenadress, newpassportId);
        //_setTokenURI(newpassportId, tokenURI_);
        tokenIdByAddress[citizenadress]= newpassportId;
        adressByTokenid[newpassportId] = citizenadress;
        

        _tokenIds.increment();
        numberOfPassport++;

        return newpassportId;
    }
    function gettokenid() public view onlyOwner returns(uint256){
        return _tokenIds.current();

    }
    function getnumberOfPassport() public view returns(uint256){
        return numberOfPassport;
    }
    function revokePassport(uint256 tokenId) public onlyOwner whenNotPaused returns (uint256 _tokenId)
    {   
        passport.safeBurn(tokenId);
        address tokenOwnerAdress = adressByTokenid[tokenId];
        delete tokenIdByAddress[tokenOwnerAdress];
        delete adressByTokenid[tokenId];
        numberOfPassport--;

        return tokenId;
    }        
    function getPassportAddress() public view returns(address){
        return passport.getAddress();
    }
    function getAddress() public view returns(address){
        return address(this);
    }
}