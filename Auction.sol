// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Auction contract with owner-controlled finalization and partial refunds
/// @author Pablo Maestu
/// @notice Implements a timed auction with incremental bids, commission, partial refunds and emergency withdrawal
contract Auction {
    address public owner;
    uint public auctionEndTime;
    address public highestBidder;
    uint public highestBid;
    bool public auctionEnded;
    uint public commissionRate = 2; // 2% commission
    uint public minIncrementPercent = 5; // Minimum 5% increase to outbid
    uint public extensionTime = 10 minutes;

    mapping(address => uint) public bids;
    mapping(address => uint[]) public bidHistory;
    mapping(address => uint) public refundableBalances;

    address[] private biddersList;

    event NewBid(address indexed bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    event PartialRefund(address indexed bidder, uint amount);

    /// @notice Restricts function usage to the contract owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "notOwner"); // MODIFIED: Added onlyOwner modifier for restricted functions
        
        _;
    }

    /// @notice Initializes auction with a set duration in minutes
    /// @param _durationInMinutes Duration the auction lasts
    constructor(uint _durationInMinutes) {
        owner = msg.sender; // MODIFIED: Set contract deployer as owner
        auctionEndTime = block.timestamp + (_durationInMinutes * 1 minutes);
    }

    /// @notice Returns remaining time of the auction in seconds
    /// @return Remaining seconds of the auction, 0 if ended
    function timeLeft() external view returns (uint) {
        if (block.timestamp >= auctionEndTime) {
            return 0;
        } else {
            return auctionEndTime - block.timestamp;
        }
    }

    /// @notice Place a bid in the auction
    /// @dev Minimum bid must be 5% higher than current highest unless first bid
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "ended");
        require(msg.value > 0, "zero");

        uint minimumRequired = highestBid == 0 ? 0 : highestBid + (highestBid * minIncrementPercent) / 100;
        require(msg.value > minimumRequired, "lowBid");

        if (bids[msg.sender] > 0) {
            refundableBalances[msg.sender] += bids[msg.sender];
        } else {
            biddersList.push(msg.sender);
        }

        bids[msg.sender] = msg.value;
        bidHistory[msg.sender].push(msg.value);

        highestBidder = msg.sender;
        highestBid = msg.value;

        if (auctionEndTime - block.timestamp <= extensionTime) {
            auctionEndTime += extensionTime;
        }

        emit NewBid(msg.sender, msg.value);
    }

    /// @notice View the current winner and highest bid
    /// @return winner Address of highest bidder
    /// @return bid Highest bid amount
    function showWinner() external view returns (address winner, uint bid) {
        return (highestBidder, highestBid);
    }

    /// @notice Get bidding history for a specific address
    /// @param bidder Address of the bidder
    /// @return Array of all bids placed by the bidder
    function showBidHistory(address bidder) external view returns (uint[] memory) {
        return bidHistory[bidder];
    }

    /// @notice Withdraw refundable previous bids (partial refund)
    function withdrawPartialRefund() external {
        uint amount = refundableBalances[msg.sender];
        require(amount > 0, "noRefund");

        refundableBalances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit PartialRefund(msg.sender, amount);
    }

    /// @notice Finalizes the auction. Only callable by owner after auction ends
    function endAuction() external onlyOwner {
        require(block.timestamp >= auctionEndTime, "ongoing");
        require(!auctionEnded, "ended");

        auctionEnded = true;

        uint commission = (highestBid * commissionRate) / 100;
        payable(owner).transfer(commission);

        uint length = biddersList.length;
        for (uint i = 0; i < length; i++) {
            address bidder = biddersList[i];
            if (bidder != highestBidder) {
                uint refundAmount = bids[bidder];
                if (refundAmount > 0) {
                    bids[bidder] = 0;
                    payable(bidder).transfer(refundAmount);
                }
            }
        }

        emit AuctionEnded(highestBidder, highestBid);
    }

    /// @notice Emergency recovery of ETH by owner after auction ends
    function emergencyWithdraw() external onlyOwner {
        require(auctionEnded, "notFinalized");
        payable(owner).transfer(address(this).balance);
    }
}
