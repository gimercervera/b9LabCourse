pragma solidity ^0.4.10;

contract Splitter {
  address public address1;
  address public address2;
  address public owner;
  bool public isKilled;
  
  mapping(address => uint) public splitBalance;
  
  modifier onlyOwner(){
    require(msg.sender == owner);
    _;
  }
  
  modifier onlyIfRunning(){
      require(isKilled != true);
      _;
  }
  
  modifier haveBalance(){
    require(splitBalance[msg.sender] > 0);
    _;
  }

  event LogSplit(address sender, address receiver1, uint amount1, address receier2, uint amount2);
  event LogCheckBalance(address sender, uint senderBalance, uint totalBalance);
  event LogKillContract(address sender, string message, bool status);
  
  function Splitter()
    public
  {
    owner = msg.sender;
  }
  
  function split (address receiver1, address receiver2)
    public
    payable
    onlyIfRunning()
    returns (bool)
  {
    //check if the address arguments are not empty
    require(receiver1!=address(0x0));
    require(receiver2!=address(0x0));
    
    //Check if the sender has enough funds.
    require(msg.sender.balance > msg.value);
    require(msg.value > 0);
    
    address1 = receiver1; //Receiver 1
    address2 = receiver2; //Receiver 2
    
    uint part1 = msg.value/2;
    uint part2 = msg.value - part1;
    
    splitBalance[address1] += part1;
    splitBalance[address2] += part2;
    
    //LogSplit(msg.sender, address1, splitBalance[address1], address2, splitBalance[address2]);
    
    return true;
  }
  
  function getSplitBalance(address addr) returns(uint){
    return splitBalance[addr];
  }


  function withdraw()
    public
    haveBalance()
    onlyIfRunning()
    returns(bool)
  {
      uint amount = splitBalance[msg.sender];
      splitBalance[msg.sender] = 0;
      
      msg.sender.transfer(amount);
      
      LogCheckBalance(msg.sender, splitBalance[msg.sender], msg.sender.balance);
      
      return true;
  }
  
  function killContract(bool statusContract)
    public 
    onlyOwner() 
  {
    //initial value: false
    isKilled = statusContract;
    LogKillContract(msg.sender, "Owner updated the status of the contract", isKilled);
  }
  
  function() public {}
}