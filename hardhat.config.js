//0x8E915DF57C6180a5fb1C524087f7ade7c920f38c
// when i was facing issue related to hardhat this i import this library and it start working
///// npm install --save-dev hardhat hardhat-ethers ethers
//https://goerli.etherscan.io/tx/0x88b192f45a72c15c63033c404f8a7866246449a48ff89fd0b8560fb9fbe9984c
require("@nomiclabs/hardhat-waffle");

const ALCHEMY_API_KEY = "-4leZZz1LY5YU2y2C_ApxmCepY_Iyd0t";
const goerli_PRIVATE_KEY = "9d241954b3bd3fe02337a657dc8e0c7cede159b8ab67b5382f746b05a7324b5d";
module.exports = {
  solidity: "0.8.4",
  paths: {
    artifacts: './artifacts',
  },
  networks: {
    goerli:  {
      url: `https://eth-goerli.g.alchemy.com/v2/-4leZZz1LY5YU2y2C_ApxmCepY_Iyd0t`,
      accounts: [`${goerli_PRIVATE_KEY}`],
    },
  },
};