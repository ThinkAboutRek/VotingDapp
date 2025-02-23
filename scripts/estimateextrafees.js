const { ethers } = require("hardhat");

// Load the WitnetOracle ABI from the artifacts (adjust the path as needed)
const oracleAbi = require("../artifacts/witnet-solidity-bridge/contracts/WitnetOracle.sol/WitnetOracle.json").abi;

// Official Witnet Oracle address on Polygon Amoy (verify this on Polygonscan)
const oracleAddress = "0x77703aE126B971c9946d562F41Dd47071dA00777";

// (Optional) Use the Witnet Request Hash you generated earlier, if needed for comparison.
// const witnetRequestHash = "0xe81deeee02078e907c465ac88c2e133b0e34940144aa4cea09c37297d8f3ea57";

async function main() {
  // Get a signer (deployer) from Hardhat.
  const [deployer] = await ethers.getSigners();
  console.log("Deployer address:", deployer.address);

  // Instantiate the Witnet Oracle contract.
  const oracle = new ethers.Contract(oracleAddress, oracleAbi, deployer);

  // Define a gas price for estimation purposes (e.g., 1 gwei).
  const gasPrice = ethers.parseUnits("1", "gwei");
  
  // Define an evmWitPrice value for estimation (for example, 1 gwei).
  const evmWitPrice = ethers.parseUnits("1", "gwei");

  // Define your SLA as expected by WitnetV2, which only includes committeeSize and witnessingFeeNanoWit.
  const sla = {
    committeeSize: 2,            // Example value (must be >0 and <=127)
    witnessingFeeNanoWit: 2      // Example minimal fee in nanoWIT (must be > 0)
  };

  // Try to call the extra fee estimation function.
  // We explicitly specify the function signature to disambiguate the overload.
  try {
    const estimatedExtraFee = await oracle["estimateExtraFee(uint256,uint256,(uint8,uint64))"](gasPrice, evmWitPrice, sla);
    console.log("Estimated Extra Fee:", estimatedExtraFee.toString());
  } catch (error) {
    console.error("Failed to call estimateExtraFee:", error);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
