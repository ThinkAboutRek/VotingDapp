
async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  // Get the contract factory and deploy the contract
  const Voting = await ethers.getContractFactory("Voting");

  // pass the Witnet Oracle and verification contract addresses
  const witnetOracleAddress = "0xYourOracleAddress";  // Placeholder
  const verificationRequestAddress = "0xYourVerificationRequestAddress";  // Placeholder

  const voting = await Voting.deploy(witnetOracleAddress, verificationRequestAddress);
  await voting.deployed();

  console.log("Voting contract deployed to:", voting.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
