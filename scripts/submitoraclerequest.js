const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Submitting Witnet Request:", deployer.address);

  // Fetch the balance using the provider
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "POL");
  const voting = await ethers.getContractAt("VotingWithOracle", "0x56a8498bc8471c4207a9ec20c30c442da4729e35");
  const witnetRequestHash = "0xe81deeee02078e907c465ac88c2e133b0e34940144aa4cea09c37297d8f3ea57"; // The hash generated from your JS script.
  const sla = {
    committeeSize: 2,            // minimal committee size
    witnessingFeeNanoWit: 2      // minimal fee (in nanoWIT) per witness
  };
  
  
  
  const tx = await voting.submitOracleRequest(witnetRequestHash, sla, { value: ethers.parseEther("1") });
  await tx.wait();
  console.log("Oracle request submitted successfully!");
  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
