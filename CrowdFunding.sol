//SPDX-License Identifier: MIT
pragma solidity >=0.6.6 <0.9.0;

contract CrowdFunding{

    mapping(address=>uint) public contributors;
    uint256 public deadline;
    uint256 public target;
    uint public minContribution;
    address public manager;
    uint public raisedAmount;
    uint256 public noOfContributors;

struct Request{
    string description;
    address payable recipient;
    uint value;
    bool completed;
    uint noOfVoters;
    mapping(address=>bool) voters;
}
mapping(uint=>Request) public requets;
uint public numRequest;
constructor(uint _target, uint _deadline) public{
    target = _target;
    deadline =block.timestamp+_deadline;
    minContribution = 100 wei;
    manager=msg.sender;
}

function sendEth() public payable{
    require(block.timestamp < deadline , "Deadline has Passed");
    require(msg.value >=minContribution, "Amount is Not matched Above min Contribution");
    if(contributors[msg.sender]==0){
        noOfContributors++;
    }
    contributors[msg.sender]+=msg.value;
    raisedAmount+=msg.value;
}

function getContractBalance() public view returns(uint){
    return address(this).balance;
}

function refund() public{
    require(block.timestamp>deadline && raisedAmount<target , "You are not eligible for Refund");
    require(contributors[msg.sender]>0);
    address payable user =payable(msg.sender);
    user.transfer(contributors[msg.sender]);
    contributors[msg.sender]==0;
}
 
 modifier onlyManager(){
     require(msg.sender==manager, "Only Manager can Access");
     _;
 }

function createRequests(string memory _description, address payable _recipient, uint _value) public onlyManager{
    require(_value<=target, "You Have Entered More Amount");
    Request storage newRequest = requets[numRequest];
    numRequest++;
    newRequest.description= _description;
    newRequest.recipient= _recipient;
    newRequest.value= _value;
    newRequest.completed=false;
    newRequest.noOfVoters=0;
}
function voteRequest(uint _requestNo) public{
    require(contributors[msg.sender]>0,"you must be a contributor");
    Request storage thisRequest = requets[_requestNo];
    require(thisRequest.voters[msg.sender]==false,"You have Already voted");
    thisRequest.noOfVoters++;
}

function makePayment(uint _requestNo) public onlyManager{
   require(raisedAmount>=target);
    Request storage thisRequest = requets[_requestNo];
    require(thisRequest.completed==false,"The request has been completed");
    require(thisRequest.noOfVoters> noOfContributors/2);
    thisRequest.recipient.transfer(thisRequest.value);
    thisRequest.completed==true;
}
}
