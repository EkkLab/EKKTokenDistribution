pragma solidity ^0.4.20;

import "./EKK.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./oraclizeAPI_0.5.sol";


contract EKKDistribution is Ownable, usingOraclize {
    
    using SafeMath for uint256;
    uint256 CampaignPeriod = 600;
    uint256 EverytimePeriod = 82800; //Every 23 hours
    uint currentPeriod = 0;
    // address where funds are collected
    address public wallet;
    EKK public token;
    
    struct Investor {
        address addr;
        uint256 amount;
    }
    
    struct Campaign {
        uint numInvestors;
        uint256 AllContribution;
        mapping(uint => Investor) investors;
    }
    
    mapping (uint => Campaign) campaigns;
    

    
    // start token Distribution
    function start() onlyOwner public {
        campaigns[currentPeriod] = Campaign(0,0);
        Alarm();
    }
    

    function Alarm() internal {
        oraclize_query(EverytimePeriod, "URL", "");
    }

    function __callback(bytes32 myid, string result) {
        
        if(msg.sender != oraclize_cbAddress()) throw;
        TokenDistribution();
        currentPeriod++;
        if(currentPeriod < CampaignPeriod) Alarm();
    }
    
    function EKKDistribution(address _tokenaddress) {
        wallet = msg.sender;
        token = EKK(_tokenaddress);
    }
    
    function () payable {
        
    }
    function TokenDistribution() {
        
    }
}