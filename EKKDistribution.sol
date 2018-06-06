pragma solidity ^0.4.20;

import "./EKK.sol";
import "./SafeMath.sol";
import "./Ownable.sol";


contract EKKDistribution is Ownable {
    
    using SafeMath for uint256;
    uint256 CampaignPeriod = 600;
    uint256 TokenPerPeriod = 1000000 * 10**uint256(18);
    uint256 EverytimePeriod = 82800; //Every 23 hours
    uint256 minimumInvestment = 100 finney;
    
    uint public  startTime;            // start time

    mapping (uint => uint)   public  periodAllContribution;
    mapping (uint => mapping (address => uint))  public  userBuys;
    mapping (uint => mapping (address => bool))  public  claimed;

    // address where funds are collected
    address public wallet;
    EKK public token;
    
    event LogBuy (uint day, address user, uint amount);
    event LogClaim (uint day, address user, uint amount);
    
    function EKKDistribution(address _tokenaddress) {
        wallet = msg.sender;
        token = EKK(_tokenaddress);
    }
    
    function time() constant returns (uint) {
        return block.timestamp;
    }

    function currentperiod() constant returns (uint) {
        return dayFor(time());
    }

    // Each window is 23 hours long so that end-of-window rotates
    // around the clock for all timezones.
    function dayFor(uint timestamp) constant returns (uint) {
        return timestamp < startTime
            ? 0
            : timestamp.sub(startTime) / 23 hours + 1;
    }
    
    function setStarttime(uint _starttime) onlyOwner public {
        startTime = _starttime;
    }
    function setWalletAddress(address _wallet) onlyOwner public {
        wallet = _wallet;
    }
    
    
    function buytokens(uint day) internal {
        require(currentperiod() > 0 && currentperiod() <= CampaignPeriod);
        require(msg.value >= minimumInvestment);

        userBuys[day][msg.sender] += msg.value;
        periodAllContribution[day] += msg.value;

        LogBuy(day, msg.sender, msg.value);
    }

    function buy() payable {
       buytokens(currentperiod());
    }

    function () payable external{
       buy();
    }
    
    
    function claim(uint day) public {
        
        require(currentperiod() > day);

        if (claimed[day][msg.sender] || periodAllContribution[day] == 0) {
            return;
        }

        uint256 reward = TokenPerPeriod.mul(userBuys[day][msg.sender]).div(periodAllContribution[day]);
        token.transferfromThis(msg.sender, reward);
        claimed[day][msg.sender] = true;

        LogClaim(day, msg.sender, reward);
    }

    function claimAll() public {
        for (uint i = 0; i < currentperiod(); i++) {
            claim(i);
        }
    }
    
}