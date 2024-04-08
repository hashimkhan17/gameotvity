// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CryptoWarload is ERC721URIStorage, ReentrancyGuard,Ownable(msg.sender) {
    uint256 public constant STARTER_LIMIT = 10000;
    uint256 public constant PRO_LIMIT = 16000;
    uint256 public constant ELITE_LIMIT = 19950;
    uint256 public constant KING_LIMIT = 20000;
    uint256 public constant TOTAL_LIMIT = 20000;

    uint256 public starterMinted = 1;
    uint256 public proMinted = 10001;
    uint256 public eliteMinted = 16001;
    uint256 public kingMinted = 19951;
    
    uint256 private TotalSupply = 0;

    string private baseURI;
    mapping(uint256 => uint256) public tokenRarityLevel; 

    enum RarityLevel {STARTER, PRO, ELITE, KING}

    mapping(uint256 => uint256) public maxLevelForRarity;

    constructor(string memory _name, string memory _symbol, string memory _initBaseURI) ERC721(_name, _symbol) {
        baseURI = _initBaseURI;
       
        maxLevelForRarity[uint256(RarityLevel.STARTER)] = 1;
        maxLevelForRarity[uint256(RarityLevel.PRO)] = 5;
        maxLevelForRarity[uint256(RarityLevel.ELITE)] = 12;
        maxLevelForRarity[uint256(RarityLevel.KING)] = 25;
    }
mapping (uint256 => uint256) public totalmints;

    function mintStarter(uint256 level) public {
        require(TotalSupply <= TOTAL_LIMIT, "Maximum token limit reached");
        require(starterMinted < STARTER_LIMIT, "Starter tokens sold out");
        require(level <= maxLevelForRarity[uint256(RarityLevel.STARTER)], "Invalid level for this rarity");
        _mint(msg.sender, starterMinted);
          tokenRarityLevel[starterMinted] = level;
        starterMinted++;
        TotalSupply++;
    }

    function mintPro(uint256 level) public {
        require(TotalSupply <= TOTAL_LIMIT, "Maximum token limit reached");
        require(proMinted < PRO_LIMIT, "Pro tokens sold out");
        require(level <= maxLevelForRarity[uint256(RarityLevel.PRO)], "Invalid level for this rarity");
       
        _mint(msg.sender, proMinted);
         tokenRarityLevel[proMinted] = level;
        proMinted++;
        TotalSupply++;
    }

    function mintElite(uint256 level) public {
        require(TotalSupply <= TOTAL_LIMIT, "Maximum token limit reached");
        require(eliteMinted < ELITE_LIMIT, "Elite tokens sold out");
        require(level <= maxLevelForRarity[uint256(RarityLevel.ELITE)], "Invalid level for this rarity");
        _mint(msg.sender, eliteMinted);
        tokenRarityLevel[eliteMinted] = level;
        eliteMinted++;
        TotalSupply++;
    }

    function mintKing(uint256 level) public onlyOwner {
        require(TotalSupply <= TOTAL_LIMIT, "Maximum token limit reached");
        require(kingMinted < KING_LIMIT, "King tokens sold out");
        require(level <= maxLevelForRarity[uint256(RarityLevel.KING)], "Invalid level for this rarity");
        _mint(msg.sender, kingMinted);
        tokenRarityLevel[kingMinted] = level;
        kingMinted++;
        TotalSupply++;
        
    }

    
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, Strings.toString(tokenId), ".json")) : "";
    }

 function getTokenRarity(uint256 tokenId) public view returns(uint256) {
    require(tokenRarityLevel[tokenId] != 0 , "Token does not exist");
    return tokenRarityLevel[tokenId];
}

}