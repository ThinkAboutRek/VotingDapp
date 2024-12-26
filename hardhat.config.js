require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.8.11",
  networks: {
    amoy: {
      url: "https://rpc-amoy.polygon.technology/",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 80002,
    },
    sepolia: {
      url: `https://rpc.sepolia.org`, 
      accounts: [process.env.PRIVATE_KEY], 
    },
  },
};
