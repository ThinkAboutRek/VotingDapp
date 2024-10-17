// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "witnet-solidity-bridge/contracts/WitnetOracle.sol";  

contract Voting {
    WitnetOracle public witnetOracle;    // Oracle interface for interacting with Witnet
    bool public votingActive;
    mapping(address => bool) public voters;
    mapping(uint => uint) public votes;

    event VoteCasted(address voter, uint candidateId);
    event VotingEnded();

    constructor(WitnetOracle _witnetOracle) {
        witnetOracle = _witnetOracle;
        votingActive = true;
    }

    function vote(uint candidateId) public {
        require(votingActive, "Voting is closed.");
        require(!voters[msg.sender], "You have already voted.");

        // add any external check using Witnet here before allowing the vote
        // Ensure external verification is complete (if used for identity check or external API)

        voters[msg.sender] = true;
        votes[candidateId] += 1;

        emit VoteCasted(msg.sender, candidateId);
    }

    function endVoting() public {
        votingActive = false;
        emit VotingEnded();
    }

    // Example function to verify oracle data
    function verifyWithOracle() public pure returns (bool) {
        // You can add oracle data check here and return true/false
        return true;  // Modify this logic as per oracle's output
    }
}
