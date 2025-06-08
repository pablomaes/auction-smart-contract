// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    address public owner;
    uint public auctionEndTime;
    address public highestBidder;
    uint public highestBid;
    bool public auctionEnded;
    uint public commissionRate = 2; // 2% commission
    uint public minIncrementPercent = 5; // Minimum 5% increase to outbid
    uint public extensionTime = 10 minutes;

    mapping(address => uint) public bids; // Tracks current bid per bidder
    mapping(address => uint[]) public bidHistory; // Tracks bid history per bidder
    mapping(address => uint) public refundableBalances; // Tracks refundable partial deposits

    address[] private biddersList; // List of all bidders for refund processing

    event NewBid(address indexed bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    event PartialRefund(address indexed bidder, uint amount);

    /// @notice Initializes auction duration in minutes
    /// @param _durationInMinutes Duration the auction lasts
    constructor(uint _durationInMinutes) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + (_durationInMinutes * 1 minutes);
    }
/// @notice Returns the remaining time of the auction in seconds
function timeLeft() public view returns (uint) {
    if(block.timestamp >= auctionEndTime) {
        return 0;
    } else {
        return auctionEndTime - block.timestamp;
    }
}

    /// @notice Place a bid in the auction
    function placeBid() public payable {
        require(block.timestamp < auctionEndTime, "Auction already ended");
        require(msg.value > 0, "Bid must be greater than 0");

        uint minimumRequired = highestBid + (highestBid * minIncrementPercent) / 100;
        if (highestBid == 0) {
            minimumRequired = 0; // First bid can be any positive amount
        }
        require(msg.value > minimumRequired, "Bid must be at least 5% higher than current highest");

        // If bidder had previous bid, add it to refundable balance for partial refund later
        if (bids[msg.sender] > 0) {
            refundableBalances[msg.sender] += bids[msg.sender];
        } else {
            // New bidder: add to bidders list
            biddersList.push(msg.sender);
        }

        // Update bidder's current bid and history
        bids[msg.sender] = msg.value;
        bidHistory[msg.sender].push(msg.value);

        // Update highest bidder and highest bid
        highestBidder = msg.sender;
        highestBid = msg.value;

        // Extend auction if bid placed within last 10 minutes
        if (auctionEndTime - block.timestamp <= extensionTime) {
            auctionEndTime += extensionTime;
        }

        emit NewBid(msg.sender, msg.value);
    }

    /// @notice Returns winner and highest bid amount
    function showWinner() public view returns (address, uint) {
        return (highestBidder, highestBid);
    }

    /// @notice Returns bid history array for given bidder
    /// @param bidder Address of the bidder
    function showBidHistory(address bidder) public view returns (uint[] memory) {
        return bidHistory[bidder];
    }

    /// @notice Allows bidders to withdraw refundable partial deposits
    function withdrawPartialRefund() public {
        uint amount = refundableBalances[msg.sender];
        require(amount > 0, "No refundable balance available");

        refundableBalances[msg.sender] = 0;

        payable(msg.sender).transfer(amount);

        emit PartialRefund(msg.sender, amount);
    }

    /// @notice Ends the auction, sends commission to owner and refunds to non-winners
    function endAuction() public {
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        require(!auctionEnded, "Auction end already called");

        auctionEnded = true;

        uint commission = (highestBid * commissionRate) / 100;
        uint ownerAmount = commission;
       

        // Transfer commission to owner
        payable(owner).transfer(ownerAmount);

        // Refund all bidders except the highest bidder
        for (uint i = 0; i < biddersList.length; i++) {
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
}
