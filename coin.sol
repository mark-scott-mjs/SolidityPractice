pragma solidity 0.7.1;

contract Coin {
    //the keyword 'public' makes variables accessible from other smart contracts
    address public minter;
    mapping(address => uint) public balances;
    
    //events allow clients to react to specific contract changes that you declare
    event Sent(address from, address to, uint amount);
    
    //constructor code is only run when the contract is created
    constructor() {
        minter = msg.sender;
    }
    
    //sends an amount of newly created coins to an address
    //can only be called by the contract creator 
    function mint(address receiver, uint amount) public {
        require(msg.sender == minter);
        require(amount < 1e60); 
        balances[receiver] += amount;
    }
    
    //sends an amount of existing coins from any caller to an address
    function send(address receiver, uint amount) public {
        require(amount <= balances[msg.sender], "Insufficient balance." )
        balances[msg.sender] -= amount; 
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}
