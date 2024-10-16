async function main() {
    // Get the contract factory and attach it to the deployed contract
    const Voting = await ethers.getContractFactory("Voting");
  
    // Replace with your deployed contract address
    const voting = await Voting.attach("0x5FbDB2315678afecb367f032d93F642f64180aa3");
  
    // Fetch and display candidate details
    const candidate1 = await voting.candidates(1);
    console.log("Candidate 1:", candidate1.name, "Votes:", candidate1.voteCount.toString());
  
    const candidate2 = await voting.candidates(2);
    console.log("Candidate 2:", candidate2.name, "Votes:", candidate2.voteCount.toString());
  
    // Vote for candidate 1 from the second account (accounts[2])
    const accounts = await ethers.getSigners();
    console.log("Voting from account:", accounts[2].address);
    const voteTx = await voting.connect(accounts[2]).vote(1);
    await voteTx.wait(); // Wait for the transaction to be mined
    console.log("Vote transaction completed!");
  
    // Fetch updated vote count
    const updatedCandidate1 = await voting.candidates(1);
    console.log("Updated Candidate 1 Votes:", updatedCandidate1.voteCount.toString());
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  