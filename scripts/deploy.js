const hre = require("hardhat"); // Load Hardhat Runtime Environment

async function main() {
  // Retrieve the contract factory for "Voting"
  const Voting = await hre.ethers.getContractFactory("Voting");
  
  // Deploy the Voting contract
  const voting = await Voting.deploy();
  
  // Wait for the contract deployment to be completed
  await voting.deployed();

  // Log the contract address after deployment
  console.log("Voting contract deployed to:", voting.address);
}

// Call the main function and handle errors
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
