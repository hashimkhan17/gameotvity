// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts@4.7.3/utils/Strings.sol";

contract MyERC721AContract is ERC721A, Ownable(msg.sender) {
    string private baseURI;

    constructor(string memory _name, string memory _symbol, string memory _initBaseURI) ERC721A(_name, _symbol) {
        setBaseURI(_initBaseURI);
    }

    function mint(uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(_mintAmount > 0, "need to mint at least 1 NFT");
        _safeMint(msg.sender, _mintAmount);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? 
               string(abi.encodePacked(currentBaseURI, Strings.toString(tokenId), ".json")) : 
               "";
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}