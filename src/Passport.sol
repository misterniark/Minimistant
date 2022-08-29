// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {ERC721Burnable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";

/**
* @title Passport for network City
* @dev non-transferable, burnable ERC721 use as passport for the City
 */

contract Passport is ERC721, ERC721Enumerable, Ownable,  ERC721Burnable {

    event NewNFTPassort(address _adress,uint256 passportId);
    event PassortStrated(string _name,string _symbol);

     address private _owner;


    constructor( string memory name, string memory symbol, address owner_) ERC721(name,symbol) {
        _owner = owner_;

        emit PassortStrated(name,symbol);
    }

    function safeMint(address to, uint256 tokenId) external onlyOwner {
        require(
            balanceOf(to) < 1, "ALREDYHAVEONE"
        );
        _safeMint(to, tokenId);
        _approve(msg.sender, tokenId);
    }
    function safeBurn(uint256 tokenId) external onlyOwner {
        _burn(tokenId);

    }
    function _burn(uint256 tokenId) internal override (ERC721) onlyOwner {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        /** 
        * @dev non-transferable, burnable ERC721
        */
        require(from == address(0) || to == address(0), "NonTransferrableERC721Token");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    function getAddress() public view returns(address){
        return address(this);
    }
}

