// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "witnet-solidity-bridge/contracts/WitnetOracle.sol";
import "witnet-solidity-bridge/contracts/libs/WitnetV2.sol";

contract Voting {
    WitnetOracle public witnetOracle; // Witnet Oracle interface for external data
    address public owner; // Owner of the contract
    bool public votingActive;
    mapping(address => bool) public voters; // Tracks voter addresses
    mapping(uint => uint) public candidateVotes; // Tracks votes for each candidate
    uint[] public candidates; // Dynamic list of candidates
    uint256 public votingStartTime;
    uint256 public votingEndTime;
    bool public resultsFinalized;
    bool private locked; // Reentrancy lock

    event VoteCasted(address voter, uint candidateId);
    event CandidateAdded(uint candidateId);
    event CandidateRemoved(uint candidateId);
    event VotingStarted(uint256 startTime, uint256 endTime);
    event VotingEnded();
    event OracleRequestCreated(uint256 requestId);
    event OracleDataVerified(uint256 requestId, bool valid);
    event ResultsFinalized();

    constructor(WitnetOracle _witnetOracle) {
        witnetOracle = _witnetOracle;
        owner = msg.sender; // Set the deployer as the owner
        votingActive = true;
        resultsFinalized = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    modifier votingIsActive() {
        require(votingActive, "Voting is not active.");
        _;
    }

    modifier votingIsWithinPeriod() {
        require(
            block.timestamp >= votingStartTime && block.timestamp <= votingEndTime,
            "Voting is not within the allowed period."
        );
        _;
    }

    modifier nonReentrant() {
        require(!locked, "Reentrancy detected!");
        locked = true;
        _;
        locked = false;
    }

    // Add a new candidate
    function addCandidate(uint candidateId) public onlyOwner votingIsActive {
        require(!isCandidateExists(candidateId), "Candidate already exists.");
        candidates.push(candidateId);
        emit CandidateAdded(candidateId);
    }

    // Remove an existing candidate
    function removeCandidate(uint candidateId) public onlyOwner votingIsActive {
        require(isCandidateExists(candidateId), "Candidate does not exist.");
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i] == candidateId) {
                candidates[i] = candidates[candidates.length - 1];
                candidates.pop();
                delete candidateVotes[candidateId];
                emit CandidateRemoved(candidateId);
                break;
            }
        }
    }

    // Set the voting period
    function setVotingPeriod(uint256 _startTime, uint256 _endTime) public onlyOwner {
        require(_endTime > _startTime, "End time must be after start time.");
        votingStartTime = _startTime;
        votingEndTime = _endTime;
        emit VotingStarted(_startTime, _endTime);
    }

    // Cast a vote after verifying with the Witnet Oracle
    function vote(uint candidateId, uint256 requestId) public votingIsActive votingIsWithinPeriod nonReentrant {
        require(!voters[msg.sender], "You have already voted.");
        require(isCandidateExists(candidateId), "Invalid candidate ID.");
        require(verifyWithOracle(requestId), "Verification via oracle failed.");

        voters[msg.sender] = true;
        candidateVotes[candidateId] += 1;

        emit VoteCasted(msg.sender, candidateId);
    }

    // End the voting process
    function endVoting() public onlyOwner {
        votingActive = false;
        emit VotingEnded();
    }

    // Finalize the results
    function finalizeResults() public onlyOwner {
        require(!votingActive, "Voting is still active.");
        resultsFinalized = true;
        emit ResultsFinalized();
    }

    // Submit a request to the Witnet Oracle
    function submitOracleRequest(
        bytes32 witnetRequestHash,
        WitnetV2.RadonSLA memory sla
    ) public payable onlyOwner returns (uint256 requestId) {
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
    function getCandidateVotes(uint candidateId) public view returns (uint) {
        require(isCandidateExists(candidateId), "Invalid candidate ID.");
        return candidateVotes[candidateId];
    }

    // Check if an address has voted
    function hasVoted(address voter) public view returns (bool) {
        return voters[voter];
    }

    // Check if a candidate exists
    function isCandidateExists(uint candidateId) internal view returns (bool) {
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i] == candidateId) {
                return true;
            }
        }
        return false;
    }
}
