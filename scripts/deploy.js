// 0x73bA5748aF1df5C1b0A9Bd8e7E2a2fF07F0140c5 DEPLOYED ON THE SEPOLIA CHAIN
const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  // Fetch the balance using the provider
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "ETH");

  // Replace this with the correct Witnet Oracle address
  const witnetOracleAddress = "0x77703aE126B971c9946d562F41Dd47071dA00777";

  // Deploy the Voting contract
  const Voting = await ethers.getContractFactory("Voting");
  const voting = await Voting.deploy(witnetOracleAddress);

  await voting.waitForDeployment();

  console.log("Voting contract deployed to:", await voting.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
