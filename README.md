# Decentralized Voting System

## Project Overview

The **Decentralized Voting System** is an individual project developed as part of the third-year Bachelor's degree in Computer Science. It is a blockchain-based voting platform that ensures transparency, security, and immutability by using smart contracts deployed on a decentralized blockchain network.

The goal of this project is to provide a tamper-proof voting solution where every vote is recorded immutably on the blockchain, ensuring transparency in the election process while protecting voter privacy. The system will be deployed on a testnet (such as **Polygon Mumbai**), offering a real-world simulation with low-cost transactions.

### Key Features:
- **Immutability**: Once votes are cast, they cannot be changed, ensuring a tamper-proof election.
- **Transparency**: Votes are recorded on a public blockchain, making the entire voting process auditable.
- **Voter Anonymity**: Protects voter identities through cryptographic mechanisms while ensuring the legitimacy of each vote.
  
## Technologies Used

- **Hardhat**: Development environment for writing, testing, and deploying Ethereum smart contracts.
- **Solidity**: The smart contract programming language used to develop voting logic.
- **Node.js**: JavaScript runtime environment for running deployment scripts and managing dependencies.
- **ethers.js**: A JavaScript library for interacting with the Ethereum blockchain and the deployed contracts.
- **Polygon (Testnet/Mainnet)**: A Layer-2 Ethereum scaling solution with low transaction fees and high throughput.
- **Git**: Version control to track and manage project development.

## Project Structure

```bash
voting-system/
├── contracts/               # Smart contracts in Solidity
│   └── Voting.sol           # Main voting smart contract
├── scripts/                 # Deployment scripts
│   └── deploy.js            # Deployment script for smart contract
├── test/                    # Unit tests for smart contracts
│   └── Voting.test.js       # Test cases for voting contract
├── README.md                # Project documentation
├── package.json             # Node.js project dependencies
└── hardhat.config.js        # Hardhat configuration file
