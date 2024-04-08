// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

contract wartoon is ChainlinkClient, ConfirmedOwner {
     using Chainlink for Chainlink.Request;
    

    uint256 public entryFee = 10000000000000000; 

    // this is chainlink related variables
    address public tokenAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    address private oracle = 0xCC79157eb46F5624204f47AB42b3906cAA40eaB7 ;
    bytes32 private jobId;
    uint256 private fee;

      address public owner1; 

      // keep in mind this is for testing
      mapping(address => uint256) public ownerbalance;
      mapping(address => uint256)  balance1;

       constructor() ConfirmedOwner(msg.sender){
        owner1 = msg.sender;
        jobId = "7d80a6386ef543a3abb52817f6707e3b";
        fee = (1 * LINK_DIVISIBILITY) / 10;

         _setChainlinkToken(tokenAddress);
         _setChainlinkOracle(0xCC79157eb46F5624204f47AB42b3906cAA40eaB7);
    } 

    //this is game logic
    struct GameRoom {
        bool status;
        address[] players;
        mapping(address => bool) hasPaid;
    }

    mapping(uint256 => GameRoom) public gameRooms;
   
  
   modifier onlyOpenRoom(uint256 roomId) {
        require(gameRooms[roomId].status == true, "Game room is closed");
        _;
    }

    modifier onlyPlayers(uint256 roomId) {
        require(gameRooms[roomId].hasPaid[msg.sender], "Player has not paid the entry fee");
        _;
    }

    // game events
    event GameRoomCreated(uint256 indexed roomId, address indexed creator);
    event PlayerJoined(uint256 indexed roomId, address indexed player);
    event GameClosed(uint256 indexed roomId, address indexed winner, uint256 prize);

    function createGameRoom(uint256 roomNo) public payable returns(uint256 roomId) {
        require(msg.value == entryFee, "Incorrect entry fee");
        uint256 roomID = roomNo;
        require(!gameRooms[roomID].hasPaid[msg.sender], "Player already joined");

        if(gameRooms[roomId].status == true)
        {
        
        gameRooms[roomId].players.push(msg.sender);
        gameRooms[roomId].hasPaid[msg.sender] = true;
        }
        else {
        gameRooms[roomID].status = true;
        gameRooms[roomID].players.push(msg.sender);
        gameRooms[roomID].hasPaid[msg.sender] = true;
    
        }  
              
    }
     mapping(bytes32 => uint256) public verificationRequests;
     mapping(bytes32 => address) public verifyRoom;
     mapping(uint256 => address) public winner;

    // function FundTransfer(uint256 _roomId) public payable returns(bool status){
      
    //     address checkOwner = msg.sender;   
    //     require(gameRooms[_roomId].status == true, "Game room does not exist");
    // }
  //this function is for apply 
  function applyForVerification(uint256 _roomId) public returns(bool){
    address checkOwner = msg.sender;  
    require(gameRooms[_roomId].status == true, "Game room does not exist");
    Chainlink.Request memory req = _buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
    string memory url = string(abi.encodePacked('https://firestore.googleapis.com/v1/projects/wartoons-6a896/databases/(default)/documents/RoomManager/', toString(_roomId)));
       
        req._add('get', url); 
        req._add('path', 'fields,walletaddress,stringValue');
 
   bytes32 requestId = _sendChainlinkRequest(req, fee); 
   verificationRequests[requestId] = _roomId;
   verifyRoom[requestId] = checkOwner;
  return true;
}

    function fulfill(bytes32 _requestId, string calldata _playerAddress) public recordChainlinkFulfillment(_requestId) returns (bool) {
address playerOut;
       playerOut = toAddressF(_playerAddress);
       uint256 roomId = verificationRequests[_requestId];

winner[roomId] = playerOut;
address checkOwner = verifyRoom[_requestId];

   require(playerOut == checkOwner, "You are not the winner");      
    uint256 i = gameRooms[roomId].players.length;

uint256 prize = (entryFee*i*80) / 100;  // 80% to the winner
uint256 gameFee = (entryFee*i*20) / 100;

        payable(checkOwner).transfer(prize);
        balance1[checkOwner] += prize;

payable(owner1).transfer(gameFee);
ownerbalance[owner1] += gameFee;
        gameRooms[roomId].status = false;
        return true;
}
    // Helper function to convert uint256 to string
    function toString(uint256 value) public pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        temp = value;

        for (uint256 i = digits; i > 0; i--) {
            buffer[--digits] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }

        return string(buffer);
    }
    
    //string to address helper function 
     function toAddressF(string calldata s) public pure returns (address) {
        bytes memory _bytes = hexStringToAddress(s);
        require(_bytes.length >= 1 + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), 1)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }
     function hexStringToAddress(string calldata s) public pure returns (bytes memory) {
        bytes memory ss = bytes(s);
        require(ss.length%2 == 0); // length must be even
        bytes memory r = new bytes(ss.length/2);
        for (uint i=0; i<ss.length/2; ++i) {
            r[i] = bytes1(fromHexChar(uint8(ss[2*i])) * 16 +
                        fromHexChar(uint8(ss[2*i+1])));
        }

        return r;

    }

     function fromHexChar(uint8 c) public pure returns (uint8) {
        if (bytes1(c) >= bytes1('0') && bytes1(c) <= bytes1('9')) {
            return c - uint8(bytes1('0'));
        }
        if (bytes1(c) >= bytes1('a') && bytes1(c) <= bytes1('f')) {
            return 10 + c - uint8(bytes1('a'));
        }
        if (bytes1(c) >= bytes1('A') && bytes1(c) <= bytes1('F')) {
            return 10 + c - uint8(bytes1('A'));
        }
        return 0;
    }
}