// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "witnet-solidity-bridge/contracts/WitnetOracle.sol";
import "witnet-solidity-bridge/contracts/libs/WitnetV2.sol";

contract Voting {
    WitnetOracle public witnetOracle; // Witnet Oracle interface for external data
    bool public votingActive;
    mapping(address => bool) public voters; // Tracks voter addresses
    mapping(uint => uint) public votes; // Tracks votes for candidates

    event VoteCasted(address voter, uint candidateId);
    event VotingEnded();
    event OracleRequestCreated(uint256 requestId);
    event OracleDataVerified(uint256 requestId, bool valid);

    constructor(WitnetOracle _witnetOracle) {
        witnetOracle = _witnetOracle;
        votingActive = true;
    }

    // Cast a vote after verifying with the Witnet Oracle
    function vote(uint candidateId, uint256 requestId) public {
        require(votingActive, "Voting is closed.");
        require(!voters[msg.sender], "You have already voted.");
        require(verifyWithOracle(requestId), "Verification via oracle failed.");

        voters[msg.sender] = true;
        votes[candidateId] += 1;

        emit VoteCasted(msg.sender, candidateId);
    }

    // End the voting process
    function endVoting() public {
        votingActive = false;
        emit VotingEnded();
    }

    // Submit a request to the Witnet Oracle
    function submitOracleRequest(
        bytes32 witnetRequestHash,
        WitnetV2.RadonSLA memory sla
    ) public payable returns (uint256 requestId) {
        requestId = witnetOracle.postRequest{value: msg.value}(
            witnetRequestHash,
            sla
        );
        emit OracleRequestCreated(requestId);
        return requestId;
    }

    // Verify oracle data for eligibility or other criteria
    function verifyWithOracle(uint256 requestId) public returns (bool) {
        // Ensure the query has been finalized
        WitnetV2.QueryStatus queryStatus = witnetOracle.getQueryStatus(
            requestId
        );
        require(
            queryStatus == WitnetV2.QueryStatus.Finalized,
            "Request is not finalized."
        );

        // Check the response status to ensure it has been delivered
        WitnetV2.ResponseStatus responseStatus = witnetOracle
            .getQueryResponseStatus(requestId);
        require(
            responseStatus == WitnetV2.ResponseStatus.Delivered,
            "Request failed or not delivered."
        );

        // Fetch and decode the result
        bytes memory result = witnetOracle.getQueryResultCborBytes(requestId);
        bool isValid = abi.decode(result, (bool));

        emit OracleDataVerified(requestId, isValid);
        return isValid;
    }

    // Get vote count for a candidate
    function getVoteCount(uint candidateId) public view returns (uint) {
        return votes[candidateId];
    }

    // Check if an address has voted
    function hasVoted(address voter) public view returns (bool) {
        return voters[voter];
    }
}
