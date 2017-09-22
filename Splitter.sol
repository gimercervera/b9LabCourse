pragma solidity ^0.4.10;

contract Splitter {
  address public bob;
  address public carol;
  address public owner;
  bool public isKilled;
  
  mapping(address => uint) public splitBalance;
  
  modifier isCreator(){
    require(msg.sender == owner);
    _;
  }
  
  modifier haveBalance(){
    require(splitBalance[msg.sender] > 0);
    _;
  }

  event LogBalance(string name, address receiver, uint amount);
  event LogKillContract(string message, address sender);
  
  function Splitter(address bobAddress, address carolAddress) 
    payable
    public
  {
    require(bobAddress!=address(0x0));
    require(carolAddress!=address(0x0));
    
    owner = msg.sender;
    bob = bobAddress; //Receiver 1
    carol = carolAddress; //Receiver 2
  }
  
  function split ()
    public
    payable
    returns (bool)
  {
    require(!isKilled);
    require(msg.sender.balance > msg.value);
    require(msg.value > 0);
    
    uint part1 = msg.value/2;
    uint part2 = msg.value - part1;
    
    splitBalance[bob] += part1;
    splitBalance[carol] += part2;
    
    return true;
  }

  function getAllBalances() 
    public 
  {
    LogBalance("Alice", owner, owner.balance);
    LogBalance("Bob", bob, splitBalance[bob]);
    LogBalance("Carol", carol, splitBalance[carol]);
  }
  
  function getAllWallet() 
    public 
  {
    LogBalance("Alice", owner, owner.balance);
    LogBalance("Bob", bob, bob.balance);
    LogBalance("Carol", carol, carol.balance);
  }
  
  function withdraw()
    public
    haveBalance()
    returns(bool)
  {
      uint amount = splitBalance[msg.sender];
      splitBalance[msg.sender] = 0;
      
      msg.sender.transfer(amount);
      
      return true;
  }
  
  function() public {}
  
  function killContract()
    public 
    isCreator() 
  {
    isKilled = true;
    LogKillContract("Alice killed the contract", msg.sender);
    selfdestruct(msg.sender);
    
  }
}