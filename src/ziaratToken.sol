// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

// Vesting contract interface
interface IVesting {
    function release(address account) external;
}

contract ZiaratToken is ERC20, Ownable, ERC20Permit {
    uint256 public immutable maxSupply = 1_000_000_000 * 10 ** decimals(); // 1 Billion token cap
    IVesting public vestingContract; // Vesting contract interface
    // Governance-related mappings
    mapping(address => uint256) public votingPower; // Voting power for governance

    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event VestingContractUpdated(address indexed vestingContract);
    event TokensBridged(address indexed account, uint256 amount);
    event GovernanceProposalCreated(uint256 indexed proposalId, address indexed proposer, string description);
    event GovernanceProposalVoted(uint256 indexed proposalId, address indexed voter, bool support);
    event GovernanceProposalExecuted(uint256 indexed proposalId);

    struct Proposal {
        address proposer;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
    }

    Proposal[] public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // Constructor
    constructor(uint256 initialSupply) ERC20("Ziarat", "ZIAR") ERC20Permit("Ziarat") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * 10 ** decimals()); // Mint initial supply to deployer
    }

    // Governance functionality

    function createProposal(string memory description) external returns (uint256) {
        proposals.push(
            Proposal({proposer: msg.sender, description: description, votesFor: 0, votesAgainst: 0, executed: false})
        );
        uint256 proposalId = proposals.length - 1;
        emit GovernanceProposalCreated(proposalId, msg.sender, description);
        return proposalId;
    }

    function voteOnProposal(uint256 proposalId, bool support) external {
        require(proposalId < proposals.length, "Proposal does not exist");
        require(!hasVoted[proposalId][msg.sender], "You have already voted on this proposal");

        Proposal storage proposal = proposals[proposalId];
        uint256 voterPower = votingPower[msg.sender];
        require(voterPower > 0, "No voting power");

        if (support) {
            proposal.votesFor += voterPower;
        } else {
            proposal.votesAgainst += voterPower;
        }

        hasVoted[proposalId][msg.sender] = true;
        emit GovernanceProposalVoted(proposalId, msg.sender, support);
    }

    function executeProposal(uint256 proposalId) external onlyOwner {
        require(proposalId < proposals.length, "Proposal does not exist");
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.votesFor > proposal.votesAgainst, "Proposal did not pass");

        proposal.executed = true;
        emit GovernanceProposalExecuted(proposalId);
    }

    // Set the Vesting contract address (only owner)
    function setVestingContract(address _vestingContract) external onlyOwner {
        require(_vestingContract != address(0), "Invalid vesting contract address");
        vestingContract = IVesting(_vestingContract);
        emit VestingContractUpdated(_vestingContract);
    }

    // Mint new tokens (only owner, with max supply cap)
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Cannot mint to zero address");
        require(totalSupply() + amount <= maxSupply, "Cannot mint more than max supply");
        _mint(to, amount);
        emit Mint(to, amount);
    }

    // Burn tokens (only owner)
    function burn(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount);
    }

    // Release vested tokens (calls the vesting contract)
    function releaseVestedTokens(address account) external {
        require(account != address(0), "Invalid account address");
        require(address(vestingContract) != address(0), "Vesting contract is not set");
        vestingContract.release(account);
    }

    // Bridge functionality for Layer 2
    function bridgeTokens(address recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than zero");
        require(totalSupply() + amount <= maxSupply, "Cannot bridge more than max supply");

        _mint(recipient, amount);
        emit TokensBridged(recipient, amount);
    }

    // Adjust voting power for governance (only owner)
    function setVotingPower(address account, uint256 power) external onlyOwner {
        require(account != address(0), "Cannot set voting power for zero address");
        votingPower[account] = power;
    }

    function getTotalNumberOfProposals() external view returns (uint256) {
        return proposals.length;
    }

    function getVoterStatusAgaintProposal(uint256 proposalId, address account) external view returns (bool) {
        return hasVoted[proposalId][account];
    }

    function getProposalDetials(uint256 proposalId) external view returns(Proposal memory) {
        return proposals[proposalId];
    }
}
