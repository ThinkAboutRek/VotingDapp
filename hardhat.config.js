require("dotenv").config({ path: __dirname + "/.env" });

require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.17",
  networks: {
    amoy: {
      url: "https://rpc-amoy.polygon.technology/",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 80002,
    },
    // sepolia: {
    //   url: `https://rpc.sepolia.org`, 
    //   accounts: [process.env.PRIVATE_KEY], 
    // },
  },
};