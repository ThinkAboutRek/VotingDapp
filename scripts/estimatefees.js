const { ethers } = require("hardhat");

// Replace with the correct path to the WitnetOracle ABI from the witnet-solidity package.
const oracleAbi = require("../artifacts/witnet-solidity-bridge/contracts/WitnetOracle.sol/WitnetOracle.json").abi;

// Use the official Witnet Oracle address on Polygon Amoy (verify it on Polygonscan)
const oracleAddress = "0x77703aE126B971c9946d562F41Dd47071dA00777";

// Use the Witnet Request Hash you generated earlier.
const witnetRequestHash = "0xe81deeee02078e907c465ac88c2e133b0e34940144aa4cea09c37297d8f3ea57";

async function main() {
  // Get a signer (deployer) from Hardhat.
  const [deployer] = await ethers.getSigners();
  console.log("Deployer address:", deployer.address);

  // Create a contract instance of the Witnet Oracle.
  const oracle = new ethers.Contract(oracleAddress, oracleAbi, deployer);

  // Set a gas price for estimation purposes (example: 1 gwei)
  const gasPrice = ethers.parseUnits("1", "gwei");

  // Explicitly call the overload that takes (uint256, uint16)
  const estimatedBaseFee = await oracle["estimateBaseFee(uint256,uint16)"](gasPrice, 100);
  console.log("Estimated Base Fee (using resultMaxSize):", estimatedBaseFee.toString());

  // Call the estimateRandomizeFee function if available.
  const estimatedRandomizeFee = await oracle.estimateRandomizeFee(gasPrice);
  console.log("Estimated Randomize Fee:", estimatedRandomizeFee.toString());

  // If you want to use the overload that takes (uint256, bytes32), you can do:
  // const estimatedBaseFeeBytes = await oracle["estimateBaseFee(uint256,bytes32)"](gasPrice, witnetRequestHash);
  // console.log("Estimated Base Fee (using radHash):", estimatedBaseFeeBytes.toString());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
