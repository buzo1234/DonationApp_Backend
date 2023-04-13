// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract DonationContract {
    address payable public donor;
    address payable public ngo;
    uint public donationAmount;
    uint public balance;
    uint public spentAmount;
    bool public spendingApproved;

   
    uint public requestCounter;
    
    struct SpendingRequest {
        string description;
        uint amount;
        bool approved;
        address payable recipient;
    }
    SpendingRequest[] spendingReq;
    
    constructor(address payable _donor, address payable _ngo) {
        donor = _donor;
        ngo = _ngo;
        balance = 10000000000000000000000000.0;
    }
    
    modifier onlyDonor() {
        require(msg.sender == donor, "Only the donor can call this function.");
        _;
    }
    
    modifier onlyNgo() {
        require(msg.sender == ngo, "Only the NGO can call this function.");
        _;
    }
    
    function donate() external payable {
       
        require(msg.value > 0, "Donation amount must be greater than 0.");
        require(msg.sender == donor, "Only the donor can make a donation.");
        require(msg.value <= balance, "Donation amount cannot exceed the remaining balance.");
        balance -= msg.value; 
        //bool sent = ngo.send(msg.value);
        //require(sent, "Failed to send Ether");
        
    }


    
    function createSpendingRequest(string memory _description, uint _amount, address payable _recipient) external payable {
        require(_amount <= balance, "Spending request amount cannot exceed the remaining balance.");
        spendingReq.push(SpendingRequest(_description, _amount, false, _recipient));
        requestCounter++;
    
    }
    
    function approveSpendingRequest(uint _requestId) public  {
        require(spendingReq[_requestId].amount > 0, "Spending request does not exist.");
        require(!spendingReq[_requestId].approved, "Spending request has already been approved.");
        spendingReq[_requestId].approved = true;
        spentAmount += spendingReq[_requestId].amount;
    }
    
    function releaseFunds() public  payable{
        //require(spentAmount == donationAmount, "Cannot release funds until all donations are spent.");
        require(spendingApproved, "Cannot release funds until all spending proposals are approved.");
        
        requestCounter = 0;
        bool sent = ngo.send(spentAmount);
        require(sent, "Failed to send Ether");
    }
    
    function approveAllSpendingRequests() public  {
        for (uint i = 0; i < requestCounter; i++) {
            spendingReq[i].approved = true;
            spentAmount += spendingReq[i].amount;
        }
        spendingApproved = true;
    }
    
    function getDonationDetails() public view returns (address, address, uint, uint, uint, bool) {
        return (donor, ngo, donationAmount, balance, spentAmount, spendingApproved);
    }
    
    function getSpendingRequest(uint _requestId) public view returns (string memory, uint, bool, address payable) {
        return (spendingReq[_requestId].description, spendingReq[_requestId].amount, spendingReq[_requestId].approved, spendingReq[_requestId].recipient);
    }
    
    function getSpendingRequestCount() external view returns (uint) {
        return requestCounter;
    }

    function getBalance() public view returns (uint) {
        return balance;
    }

    function getAllRequests() public view returns (SpendingRequest[] memory){
 SpendingRequest[]    memory id = new SpendingRequest[](requestCounter);
      for (uint i = 0; i < requestCounter; i++) {
          SpendingRequest storage member = spendingReq[i];
          id[i] = member;
      }
      return id;
    }
}
