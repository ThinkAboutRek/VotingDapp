// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "witnet-solidity-bridge/contracts/WitnetOracle.sol";
import "witnet-solidity-bridge/contracts/libs/WitnetV2.sol";

/**
 * @title VotingWithOracle
 * @notice A decentralized voting contract that integrates off-chain identity
 * verification (via Civic) with on-chain verification (via Witnet). It uses a two-step process:
 *  1. Voter calls verifyVoterWithOracle() after receiving a finalized oracle response.
 *  2. Once verified, the voter can call castVote() to cast their vote.
 *
 * The contract also enforces clear phases: Setup (candidate management),
 * Active (voting period), and Ended.
 */
contract VotingWithOracle {
    
    /*//////////////////////////////////////////////////////////////
                              STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    
    address public owner;
    WitnetOracle public witnetOracle;
    
    // Voting phases
    enum VotingState { Setup, Active, Ended }
    VotingState public currentState;
    
    // Voting period
    uint256 public votingStartTime;
    uint256 public votingEndTime;
    
    // Candidate management
    uint[] public candidates;
    mapping(uint => bool) public candidateExists;
    mapping(uint => uint) public candidateVotes;
    
    // Voter management
    mapping(address => bool) public isVerifiedVoter;
    mapping(address => bool) public hasVoted;
    
    // Reentrancy guard
    bool private locked;
    
    /*//////////////////////////////////////////////////////////////
                               EVENTS
    //////////////////////////////////////////////////////////////*/
    
    event CandidateAdded(uint candidateId);
    event CandidateRemoved(uint candidateId);
    event VotingPeriodSet(uint256 startTime, uint256 endTime);
    event VotingStarted(uint256 startTime, uint256 endTime);
    event VotingEnded();
    event OracleRequestCreated(uint256 requestId);
    event OracleDataVerified(uint256 requestId, bool valid);
    event VoterVerified(address voter);
    event VoteCasted(address voter, uint candidateId);
    
    /*//////////////////////////////////////////////////////////////
                              MODIFIERS
    //////////////////////////////////////////////////////////////*/
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier nonReentrant() {
        require(!locked, "Reentrancy detected!");
        locked = true;
        _;
        locked = false;
    }
    
    modifier inState(VotingState _state) {
        require(currentState == _state, "Invalid state for this action");
        _;
    }
    
    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    
    constructor(WitnetOracle _witnetOracle) {
        owner = msg.sender;
        witnetOracle = _witnetOracle;
        currentState = VotingState.Setup;
    }
    
    /*//////////////////////////////////////////////////////////////
                       CANDIDATE MANAGEMENT (Setup Phase)
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Add a new candidate.
     * @param candidateId A unique numeric identifier for the candidate.
     */
    function addCandidate(uint candidateId) external onlyOwner inState(VotingState.Setup) {
        require(!candidateExists[candidateId], "Candidate already exists");
        candidates.push(candidateId);
        candidateExists[candidateId] = true;
        emit CandidateAdded(candidateId);
    }
    
    /**
     * @notice Remove an existing candidate.
     * @param candidateId The candidate's unique identifier.
     */
    function removeCandidate(uint candidateId) external onlyOwner inState(VotingState.Setup) {
        require(candidateExists[candidateId], "Candidate does not exist");
        
        // Remove candidate from array (swap and pop)
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i] == candidateId) {
                candidates[i] = candidates[candidates.length - 1];
                candidates.pop();
                break;
            }
        }
        delete candidateExists[candidateId];
        delete candidateVotes[candidateId];
        emit CandidateRemoved(candidateId);
    }
    
    /*//////////////////////////////////////////////////////////////
                         VOTING PERIOD & STATE MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Set the voting period.
     * @param _startTime Timestamp for when voting begins.
     * @param _endTime Timestamp for when voting ends.
     */
    function setVotingPeriod(uint256 _startTime, uint256 _endTime) external onlyOwner inState(VotingState.Setup) {
        require(_endTime > _startTime, "End time must be after start time");
        votingStartTime = _startTime;
        votingEndTime = _endTime;
        emit VotingPeriodSet(_startTime, _endTime);
    }
    
    /**
     * @notice Transition the contract from Setup to Active (voting) phase.
     */
    function startVoting() external onlyOwner inState(VotingState.Setup) {
        require(votingStartTime != 0 && votingEndTime != 0, "Voting period not set");
        currentState = VotingState.Active;
        emit VotingStarted(votingStartTime, votingEndTime);
    }
    
    /**
     * @notice End the voting process.
     */
    function endVoting() external onlyOwner inState(VotingState.Active) {
        currentState = VotingState.Ended;
        emit VotingEnded();
    }
    
    /*//////////////////////////////////////////////////////////////
                          ORACLE INTEGRATION
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Submit an oracle request.
     * @param witnetRequestHash The hash of the Witnet request.
     * @param sla The service level agreement parameters for the request.
     * @return requestId The unique identifier for the posted request.
     */
    function submitOracleRequest(
        bytes32 witnetRequestHash,
        WitnetV2.RadonSLA memory sla
    ) external payable onlyOwner returns (uint256 requestId) {
        requestId = witnetOracle.postRequest{value: msg.value}(witnetRequestHash, sla);
        emit OracleRequestCreated(requestId);
        return requestId;
    }
    
    /**
     * @notice After an oracle request is finalized, voters call this to verify their eligibility.
     * @param requestId The unique identifier of the oracle request.
     */
    function verifyVoterWithOracle(uint256 requestId) external {
        // Ensure the oracle request is finalized and delivered
        require(witnetOracle.getQueryStatus(requestId) == WitnetV2.QueryStatus.Finalized, "Request not finalized");
        require(witnetOracle.getQueryResponseStatus(requestId) == WitnetV2.ResponseStatus.Delivered, "Request not delivered");
        
        // Decode the result from the oracle (expected to be a boolean)
        bytes memory result = witnetOracle.getQueryResultCborBytes(requestId);
        bool isValid = abi.decode(result, (bool));
        
        require(isValid, "Oracle verification failed");
        isVerifiedVoter[msg.sender] = true;
        emit OracleDataVerified(requestId, isValid);
        emit VoterVerified(msg.sender);
    }
    
    /*//////////////////////////////////////////////////////////////
                             VOTING FUNCTIONALITY
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Cast a vote for a candidate.
     * @param candidateId The unique identifier of the candidate.
     */
    function castVote(uint candidateId) external nonReentrant inState(VotingState.Active) {
        require(block.timestamp >= votingStartTime && block.timestamp <= votingEndTime, "Not within voting period");
        require(candidateExists[candidateId], "Candidate does not exist");
        require(isVerifiedVoter[msg.sender], "Voter not verified");
        require(!hasVoted[msg.sender], "Already voted");
        
        candidateVotes[candidateId] += 1;
        hasVoted[msg.sender] = true;
        emit VoteCasted(msg.sender, candidateId);
    }
    
    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Get the list of candidate IDs.
     */
    function getCandidates() external view returns (uint[] memory) {
        return candidates;
    }
    
    /**
     * @notice Retrieve the vote count for a specific candidate.
     * @param candidateId The candidate's unique identifier.
     */
    function getCandidateVotes(uint candidateId) external view returns (uint) {
        require(candidateExists[candidateId], "Candidate does not exist");
        return candidateVotes[candidateId];
    }
    
    /**
     * @notice Compute the winner by highest vote count.
     * @return winnerId The candidate ID of the winner.
     * @return winnerVoteCount The vote count of the winner.
     */
    function getWinner() external view returns (uint winnerId, uint winnerVoteCount) {
        require(currentState == VotingState.Ended, "Voting not ended");
        uint maxVotes = 0;
        for (uint i = 0; i < candidates.length; i++) {
            uint candidateId = candidates[i];
            uint votes = candidateVotes[candidateId];
            if (votes > maxVotes) {
                maxVotes = votes;
                winnerId = candidateId;
            }
        }
        winnerVoteCount = maxVotes;
    }
}
