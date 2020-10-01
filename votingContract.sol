// SPDX-License-Identifier: GPL-3.0 
pragma solidity 0.7.1;

//@title voting with delegation
contract votingContract {
    
    //Represents a single voter, will be used for variables later
    struct Voter {
        uint weight; //weight is accumulated by delegation
        bool voted; //if true, this person already voted
        address delegate; // person vote delegated to 
        uint vote;  //index of the voted proposal 
    }
    
    //A single proposal 
    struct Proposal {
        bytes32 name; //short name 
        uint voteCount; //number of accumulated votes
    }
    
    address public chairperson;
    
    //Declares a state variable that stores a 'Voter' struct for each possible address
    mapping(address => Voter) public voters; 
    
    //Dynamically sized array of 'Proposal' structs
    Proposal[] public proposals; 
    
    //Create a new ballot to choose one of 'proposalNames'
    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender; 
        voters[chairperson].weight = 1;
        
        //For each of the provided proposal names, create a new proposal object and add it to the end of the array 
        for(uint i = 0; i < proposalNames.length; i++) {
            //Proposal({...}) creates a temporary proposal object, and proposals.push appends it to the end of proposals
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0 
            }));
        }
    }
    
    //Give voter the right to vote on this ballot, may only be called by the chairperson
    function giveRightToVote(address voter) public {
        //If the first argument of `require` evaluates to `false`, execution terminates and all changes to the state and to Ether balances are reverted.
        //This used to consume all gas in old EVM versions, but not anymore.
        //It is often a good idea to use `require` to check if functions are called correctly. 
        //As a second argument, you can also provide an explanation about what went wrong.
 
        require(msg.sender == chairperson, "Only chairperson can give the right to vote."); 
        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0);
        voters[voter].weight = 1; 
    }
    
    //Delegate your vote to the voter 'to'
    function delegate(address to) public {
        //assigns reference
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted!");
        require(to != msg.sender, "Self-delegation is not allowed."); 
        
        //Forward the delegation as long as 'to' also delegated.
        //In general, such loops are very dangerous, if they run too long, they might need more gas than is available in a block.
        //In this case, the delegation wil not be executed, in other situations such loops might cause a contract to get 'stuck'
        while(voters[to].delegate != address(0)) {
            to = voters[to].delegate; 
            
            //Found a loop in the delegation not allowed
            require(to != msg.sender, "Found loop in delegation.");
        }
        
        //Since 'sender' is a reference, this modifies voters[msg.sender].voted
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if(delegate_.voted) {
            //If the delegate already voted, directly add to the number of votes
            proposals[delegate_.vote].voteCount += sender.weight;
        } 
        else {
            //If the delegate did not vote yet, add to their weight
            delegate_.weight += sender.weight; 
        }
    }
    
    //Give your vote to proposal 'proposals[proposal].name'
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote!");
        require(!sender.voted, "Already voted!");
        sender.voted = true;
        sender.vote = proposal;
        
        //If proposal is out of the range of the array, this will throw automatically and revert all changes
        proposals[proposal].voteCount += sender.weight;
    }
    
    //@dev Computes the winning proposal taking all previous votes into account
    function winningProposal() public view returns (uint winningProposal_) {
        uint winningVoteCount = 0;
        for(uint p = 0; p < proposals.length; p++) {
            if(proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }
    
    //Calls winningProposal() function to get the index of the winner contained in the proposals array and then returns the winner
    function winnerName() public view returns(bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }
}