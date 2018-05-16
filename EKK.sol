pragma solidity ^0.4.20;

import "./EKK.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./oraclizeAPI_0.5.sol";


contract EKKDistribution is Ownable, usingOraclize {
    
    using SafeMath for uint256;
    uint256 CampaignPeriod = 600;
    uint256 TokenPerPeriod = 1000000 * 10**uint256(18);
    uint256 EverytimePeriod = 82800; //Every 23 hours
    uint public currentPeriod = 0;
    bool public DistributionStarted = false;
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
    
    mapping (uint => Campaign) public campaigns;
    
    event TokenPurchase(address indexed purchaser, uint256 amount);
    
    // start token Distribution
    function StartDistribution() onlyOwner public {
        DistributionStarted = true;
        campaigns[currentPeriod] = Campaign(0,0);
        Alarm();
    }
    

    function Alarm() internal {
        oraclize_query(EverytimePeriod, "URL", "");
    }

    function __callback(bytes32 myid, string result) {
        
        if(msg.sender != oraclize_cbAddress()) throw;
        TokenDistribution();
        if(currentPeriod < CampaignPeriod) Alarm();
        else DistributionStarted = false;
    }
    
    function EKKDistribution(address _tokenaddress) {
        wallet = msg.sender;
        token = EKK(_tokenaddress);
    }
    
    function serWalletAddress(address _wallet) onlyOwner public {
        wallet = _wallet;
    }
    function () payable external{
        require(msg.value > 0);
        require(DistributionStarted || msg.sender == owner);
        if(DistributionStarted && msg.sender != owner) {
            Campaign storage c = campaigns[currentPeriod];
            c.numInvestors++;
            c.AllContribution += msg.value;
            c.investors[c.numInvestors] = Investor({addr:msg.sender, amount:msg.value});
            wallet.transfer(msg.value);
        }
    }
    
    function TokenDistribution() internal {
        Campaign storage c = campaigns[currentPeriod];
        if(c.numInvestors >= 1) {
            for(uint i = 1; i <= c.numInvestors; i++) {
                uint256 tokenBought = TokenPerPeriod.mul(c.investors[i].amount).div(c.AllContribution);
                token.transferfromThis(c.investors[i].addr, tokenBought);
                TokenPurchase(c.investors[i].addr, tokenBought);
            }
        }
        currentPeriod++;
        campaigns[currentPeriod] = Campaign(0,0);
    }
}