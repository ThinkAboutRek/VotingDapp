const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Submitting Witnet Request from:", deployer.address);

  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "POL");

  const voting = await ethers.getContractAt(
    "VotingWithOracle",
    "0x56a8498bc8471c4207a9ec20c30c442da4729e35"
  );

  const witnetRequestHash =
    "0xe81deeee02078e907c465ac88c2e133b0e34940144aa4cea09c37297d8f3ea57";

 
  const sla = {
    committeeSize: 11,
    witnessingFeeNanoWit: 200000000
  };

  const oracleAddress = "0x77703aE126B971c9946d562F41Dd47071dA00777";
  const oracleAbi = require("./WitnetProxy.json"); 
  const oracle = new ethers.Contract(oracleAddress, oracleAbi, deployer);

  // Set gas price for estimation (now using 25 gwei)
  const gasPrice = ethers.parseUnits("25", "gwei");
  
  const estimatedBaseFee = await oracle["estimateBaseFee(uint256,bytes32)"](gasPrice, witnetRequestHash);
  console.log("Estimated Base Fee:", estimatedBaseFee.toString());

  const tx = await voting.submitOracleRequest(
    witnetRequestHash,
    sla,
    {
      value: estimatedBaseFee.toString() * 1.25,
      maxFeePerGas: gasPrice,
      maxPriorityFeePerGas: gasPrice
    }
  );
  await tx.wait();
  console.log("Oracle request submitted successfully!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
