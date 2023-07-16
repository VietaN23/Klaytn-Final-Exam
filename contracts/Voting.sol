///SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./Ownable.sol";

contract Voting is Ownable {
    uint8 public winningProposal;
    uint8 public proposalIds;
    uint8 public votersCount;

    struct Voter {
        bool isRegistered;
        address _address;
        bool hasVoted;
        uint256 votedProposalId;
    }

    struct Proposal {
        uint8 id;
        address owner;
        string description;
        uint256 voteCount;
    }

    address[] voters;
    mapping(address => Voter) public whiteList;
    mapping(uint256 => Proposal) public proposals;

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    WorkflowStatus public status;

    event NewVotingSystem();
    event VoterRegistered(address voterAddress);
    event VoterRemoved(address _address);
    event ProposalsRegistrationStarted();
    event ProposalsRegistrationEnded();
    event ProposalRegistered(uint256 proposalId);
    event ProposalRemoved(uint256 proposalId);
    event VotingSessionStarted();
    event VotingSessionEnded();
    event Voted(address voter, uint256 proposalId);
    event VotesTallied(uint8 _winningProposals);
    event WorkflowStatusChange(
        WorkflowStatus previousStatus,
        WorkflowStatus newStatus
    );

    constructor() {
        emit NewVotingSystem();
    }

    function getVoters() public view returns(address[] memory) {
        return voters;
    }

    function getWinningProposal() public view returns (Proposal memory proposal){
        return proposals[winningProposal];
    }

    function addVoter(address _address) public onlyOwner {
        require(status == WorkflowStatus.RegisteringVoters);
        Voter memory newVoter = Voter(true, _address, false, 0);
        whiteList[_address] = newVoter;
        voters.push(_address);
        votersCount++;
        emit VoterRegistered(_address);
    }

    function deleteVoter(address _address) public onlyOwner {
        delete whiteList[_address];
        votersCount--;
        emit VoterRemoved(_address);
    }

    function resetVotingSession() public onlyOwner   {
        WorkflowStatus previous = status;
        WorkflowStatus newStatus = WorkflowStatus.RegisteringVoters;
        status = newStatus;
        emit NewVotingSystem();
        emit WorkflowStatusChange(previous, newStatus);
    }


    function startProposalRegistration() public onlyOwner   {
        WorkflowStatus previous = status;
        WorkflowStatus newStatus = WorkflowStatus.ProposalsRegistrationStarted;
        status = newStatus;
        emit ProposalsRegistrationStarted();
        emit WorkflowStatusChange(previous, newStatus);
    }

    function endProposalRegistration() public onlyOwner {
        WorkflowStatus previous = status;
        WorkflowStatus newStatus = WorkflowStatus.ProposalsRegistrationEnded;
        status = newStatus;
        emit ProposalsRegistrationEnded();
        emit WorkflowStatusChange(previous, newStatus);
    }

    function startVotingSession() public onlyOwner {
        WorkflowStatus previous = status;
        WorkflowStatus newStatus = WorkflowStatus.VotingSessionStarted;
        status = newStatus;
        emit VotingSessionStarted();
        emit WorkflowStatusChange(previous, newStatus);
    }

    function endVotingSession() public onlyOwner {
        WorkflowStatus previous = status;
        WorkflowStatus newStatus = WorkflowStatus.VotingSessionEnded;
        status = newStatus;
        emit VotingSessionEnded();
        emit WorkflowStatusChange(previous, newStatus);
    }

    modifier whiteListed() {
        require(whiteList[msg.sender].isRegistered == true, "voter not whitelisted");
        _;
    }

    function addProposal(string memory _description) public whiteListed() {
        require(status == WorkflowStatus.ProposalsRegistrationStarted, "Proposals session has not started");
        Proposal memory newProposal =
        Proposal(proposalIds, msg.sender, _description, 0);
        proposals[proposalIds] = newProposal;
        proposalIds++;
        emit ProposalRegistered(proposalIds);
    }

    function deleteProposal(uint256 _id) public whiteListed {
        require(proposals[_id].owner == msg.sender);
        delete proposals[_id];
        emit ProposalRemoved(_id);
    }

    function deleteProposalAdmin(uint256 _id) public onlyOwner {
        delete proposals[_id];
    }

    function vote(uint256 _id) public whiteListed {
        require(status == WorkflowStatus.VotingSessionStarted);
        require(whiteList[msg.sender].hasVoted == false);
        whiteList[msg.sender].hasVoted = true;
        proposals[_id].voteCount++;
        emit Voted(msg.sender, _id);
    }

}
