// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.7.3/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.7.3/access/Ownable.sol";
import "@openzeppelin/contracts@4.7.3/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts@4.7.3/utils/Strings.sol";
contract Kickstar5 is ERC1155, Ownable, EIP712 {

    mapping(uint256 => uint256) public productIds;
    mapping(uint256 => uint256) public minted;

    event ItemMinted(address indexed account, uint256 indexed id, uint256 amount);
    event Withdrawal(address indexed owner, uint256 amount);

   string private constant SIGNING_DOMAIN = "Voucher-Domain";
    string private constant SIGNATURE_VERSION = "1";
    address public minter;
    
    //this is Voucher for EIP standard verification
 struct LazyNFTVoucher {
        uint256 tokenId;
        uint256 amount;
        address buyer;
        bytes signature;
    }
string OpenseaURl;
string GameURl;

constructor(address  initialOwner , string memory OpenseaURl1,string memory GameURl1 ) ERC1155("") EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) Ownable(){
        minter =  initialOwner;
         OpenseaURl = OpenseaURl1;
        GameURl = GameURl1;
     }

    event ProductAdded(uint256 indexed id, uint256 price);

    // This function is only for admin if they want to increase there items list in future

    function addProduct(uint256 id) external  {
    require(id >= 0, "Product ID must be greater than or equal to zero");
    require(productIds[id] != id, "Product already exists");
    productIds[id] = id;
    }

  function NFTmint(LazyNFTVoucher calldata voucher) public payable returns(bool) {
    uint256 id = voucher.tokenId;
    require(productIds[id] == id , "Invalid product ID");
    require(minter == recover(voucher), "Wrong signature.");
    _mint(voucher.buyer, voucher.tokenId, voucher.amount,""); // here price means 

    return true;
}

function recover(LazyNFTVoucher calldata voucher) public view returns (address) {
        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
            keccak256("LazyNFTVoucher(uint256 tokenId,uint256 amount,address buyer)"),
            voucher.tokenId,
            voucher.amount,
            voucher.buyer
        )));
        address signer = ECDSA.recover(digest, voucher.signature);
        return signer;
    }

  // this function is also for future work if infuture they want to change there stuff URL 
    function setOpenseaURI(string memory newURI) external  {
        OpenseaURl = newURI;
    }

 function setGameURI(string memory newURI) external  {
        GameURl = newURI;
    }

  function uri(uint256 _tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(OpenseaURl, Strings.toString(_tokenId)));
    }
    // this function is for game use
     function Gameuri(uint256 _tokenId) public view returns (string memory) {
        return string(abi.encodePacked(GameURl, Strings.toString(_tokenId)));
    }
}