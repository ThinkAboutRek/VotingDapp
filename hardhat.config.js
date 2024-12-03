require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.11",
  networks: {
    amoy: {
      url: "https://rpc-amoy.polygon.technology/",
      accounts: [`0a0a3d3fa2fbf2f45f0babd5446df175a7491fc02153ee5ff8c83c9ed91fd2d3`],
      chainId: 80002,
    },
    sepolia: {
      url: `https://rpc.sepolia.org`, 
      accounts: [`0a0a3d3fa2fbf2f45f0babd5446df175a7491fc02153ee5ff8c83c9ed91fd2d3`], 
    },
  },
};
