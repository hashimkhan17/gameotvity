//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts@4.7.3/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts@4.7.3/utils/Strings.sol";


contract Gameotivity is ERC20, ERC20Burnable, ERC20FlashMint, ReentrancyGuard, EIP712 {
    string private constant SIGNING_DOMAIN = "Voucher-Domain";
    string private constant SIGNATURE_VERSION = "1";
    address private admin;
    uint256 private constant MAX_SUPPLY = 1e9 * 1e18;

    mapping(address => bool) private _isTokenHolder;

    event TokensMinted(address indexed recipient, uint256 amount);
    event TokensBurned(address indexed burner, uint256 amount);

    struct UserVoucher {
        uint256 nonce;
        uint256 amount;
        address recipient;
        bytes signature;
    }

    mapping(uint256 => bool) private usedNonces;

    constructor() ERC20("Gameotivity", "GACT") EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
        _mint(msg.sender, 50000000 * 1e18);
        admin = msg.sender;
        _isTokenHolder[msg.sender] = true;
    }

    function mintTokens(UserVoucher calldata voucher) public nonReentrant {
        require(voucher.amount > 0, "Amount must be greater than 0");
        require(totalSupply() + voucher.amount <= MAX_SUPPLY, "Exceeds maximum supply");
        require(admin == recover(voucher), "Wrong signature.");
        require(!usedNonces[voucher.nonce], "Nonce already used");

        _mint(voucher.recipient, voucher.amount * 1e18);
        usedNonces[voucher.nonce] = true;

        if (!_isTokenHolder[voucher.recipient]) {
            _isTokenHolder[voucher.recipient] = true;
        }

        emit TokensMinted(voucher.recipient, voucher.amount * 1e18);
    }

    function recover(UserVoucher calldata voucher) public view returns (address) {
        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
            keccak256("UserVoucher(uint256 nonce,uint256 amount,address recipient)"),
            voucher.nonce,     
            voucher.amount,
            voucher.recipient
        
        )));
        address signer = ECDSA.recover(digest, voucher.signature);
        return signer;
    }

    function burnTokens(uint256 amount) external nonReentrant {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance to burn tokens");

        _burn(msg.sender, amount * 1e18);

        if (balanceOf(msg.sender) == 0) {
            _isTokenHolder[msg.sender] = false;
        }

        emit TokensBurned(msg.sender, amount * 1e18);
    }

    function isTokenHolder(address account) external view returns (bool) {
        return _isTokenHolder[account];
    }
}


