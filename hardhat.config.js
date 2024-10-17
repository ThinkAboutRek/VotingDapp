require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.11",
  networks: {
    amoy: {
      url: "https://rpc-amoy.polygon.technology/",
      accounts: [`0xd10903285563a63eb9996fd722faf137c52679dc3606c0c741627b3bdd953afd`], 
      chainId: 80002,
    },
  },
};
