pragma solidity 0.7.1;

contract basicToken {
    //hold the token balance of each owner account
    mapping(address => uint256) balances; 
    //include all of the accounts approved to withdraw from a given account together with the withdrawal sum allowed for each
    mapping(address => mapping(address => uint256)) allowed; 
    
    //setting the number of ICO tokens
    uint256 totalSupply;
    constructor(uint256 total) {
        totalSupply = total;
        balances[msg.sender] = totalSupply;
    }
    
    //get total token supply 
    function tokenSupply() public view returns(uint256) {
        return totalSupply;
    }
    
    //get token balance of owner
    function balanceOf(address tokenOwner) public view returns(uint){
        return balances[tokenOwner];
    }
    
    //transfer tokens to another account
    function transfer(address receiver, uint numTokens) public returns(bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - numTokens; 
        balances[receiver] = balances[receiver] + numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }
    
    //approve delegate to withdraw tokens
    function approve(address delegate, uint numTokens) public returns(bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true; 
    }
    
    //get number of tokens approved for withdrawal 
    function allowance(address owner, address delegate) public view returns(uint) {
        return allowed[owner][delegate];
    }
    
    //transfer tokens by delegate
    function transferFrom(address owner, address buyer, uint numTokens) public returns(bool) {
        //verify transaction
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        balances[owner] = balances[owner] - numTokens;
        allowed[owner][msg.sender] = allowed[from][msg.sender] - numTokens;
        balances[buyer] = balances[buyer] + numTokens;
        Transfer(owner,buyer,numTokens);
        return true;
    }
}
