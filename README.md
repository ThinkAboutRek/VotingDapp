
# Decentralized Voting System Project

## Overview
This project is a **decentralized voting system** built on the **Polygon (Amoy Testnet)** blockchain. It leverages **smart contracts** to securely collect and store votes in a tamper-resistant manner, ensuring full transparency and security. The system integrates **Civic** for decentralized identity verification to ensure that only verified users can participate in the voting process. Additionally, the project uses the **Witnet Oracle** to fetch and verify external data, ensuring trust in the voting system.

## Features
- **Blockchain-Based Voting**: Votes are securely stored on the Polygon blockchain (Amoy Testnet), ensuring full transparency and immutability.
- **Civic Identity Verification**: Only verified users, authenticated via Civic’s decentralized identity protocol, can cast a vote.
- **Witnet Oracle Integration**: Witnet is used to fetch and verify external data, enhancing trust in the voting system.
- **Decentralized and Tamper-Resistant**: Once votes are cast, they are recorded on the blockchain and cannot be altered.
- **Scalable and Cost-Effective**: The use of the Polygon Amoy testnet ensures low transaction fees while testing in a realistic blockchain environment.

## Technologies Used

1. **Solidity**: The smart contracts are written in Solidity to manage the voting system, enforce rules, and interact with external oracles.
   
2. **Polygon (Amoy Testnet)**: The project is deployed on Polygon's Amoy testnet, a low-cost and scalable alternative to Ethereum.
   
3. **Civic Identity Verification**:
   - **Civic SDK**: Used on the frontend for verifying the identity of users before they are allowed to vote.
   - **JWT Token**: Civic returns a JWT token after verification, which the smart contract validates to ensure only verified users participate.

4. **Witnet Oracle**:
   - **Witnet** is used to fetch and verify external data (such as identity verification or other relevant external data).
   - **Witnet Smart Contracts**: The system leverages **Witnet Oracle** contracts for submitting requests and fetching results in a decentralized manner.

5. **Hardhat**: A development framework for compiling, testing, and deploying smart contracts locally and on the Polygon testnet.

6. **Web3.js / Ethers.js**: Used for interacting with the blockchain and smart contracts from the frontend.

7. **React** (Frontend): The frontend is built using React, allowing users to connect their wallets, verify their identities via Civic, and cast their votes through the dApp interface.

## Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/ThinkAboutRek/Decentralized-Voting-System.git
   ```

2. **Install Dependencies**:
   ```bash
   npm install
   ```

3. **Compile Smart Contracts**:
   Compile the contracts using Hardhat:
   ```bash
   npx hardhat compile
   ```

4. **Deploy Contracts**:
   Use the provided deployment script to deploy the voting contract to the **Polygon Amoy Testnet**:
   ```bash
   npx hardhat run scripts/deploy.js --network amoy
   ```

5. **Run the Frontend**:
   To start the frontend application for Civic verification and voting:
   ```bash
   npm start
   ```

## Usage

- After deploying the contracts, users can connect their wallets via the frontend, verify their identity through Civic, and cast their votes.
- The Witnet Oracle integration ensures that trusted external data can be used to enhance the voting system’s security and verification process.

## Future Improvements
- **Additional Data Feeds**: Expanding the use of Witnet to incorporate more external data feeds (e.g., location-based voting restrictions).
- **Voting Enhancements**: Introducing other voting types like ranked-choice voting or quadratic voting.
