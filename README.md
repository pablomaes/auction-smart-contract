# 🧾 Auction Smart Contract

This project implements a timed auction smart contract using Solidity, deployed on the Sepolia testnet as a final project for Module 2 of the blockchain course. The contract includes features such as incremental bids with a minimum percentage increase, auction time extension, commission to the owner, partial refunds, and emergency withdrawal.

---

## 📍 Contract Information

- **Network:** Sepolia Testnet  
- **Deployer Address:** `0xEe03460409Ba53b6dcd65E8f0B93EC296F995eb0`  
- **Verified Contract URL:** (https://sepolia.etherscan.io/address/0x2D1148BDB5832Dde4b002D7154237be6A168Abbb#code)  
- **GitHub Repository:** https://github.com/pablomaes/auction-smart-contract

---

## ⚙️ Constructor

Initializes the auction duration in minutes and sets the deployer as the owner.

```solidity
constructor(uint _durationInMinutes)


🔥 Main Functionalities

placeBid()
Allows users to place bids before the auction ends.
Each new bid must be at least 5% higher than the current highest bid (unless it's the first bid).
If a bid is placed within the last 10 minutes, the auction end time is extended by 10 minutes.
Stores bids and bid history.
Emits the NewBid event.

timeLeft()
Returns the remaining time of the auction in seconds.
Returns 0 if the auction has ended.

showWinner()
Returns the current highest bidder and highest bid.
Callable anytime but most meaningful after auction ends.

showBidHistory(address bidder)
Returns the full bidding history of a specific address.

withdrawPartialRefund()
Allows bidders to withdraw refundable balances from previous overbid amounts.
Emits the PartialRefund event.

endAuction()
Callable only by the owner and only after the auction end time.
Marks the auction as ended.
Transfers 2% commission to the owner.
Refunds all losing bidders their bids.
Emits the AuctionEnded event.

emergencyWithdraw()
Callable only by the owner after auction finalization.
Allows withdrawal of any remaining ETH in the contract as emergency recovery.

💰 Bid and Refund Management
Bids are stored in the contract's balance.
Refunds are processed upon auction finalization (endAuction) or through withdrawPartialRefund for earlier bids that were overbid.

📌 Events
event NewBid(address indexed bidder, uint amount);
event AuctionEnded(address winner, uint amount);
event PartialRefund(address indexed bidder, uint amount);


🔒 Modifiers
onlyOwner: Restricts function access to the contract deployer (owner).

🛠 Modifications & Notes
Added onlyOwner modifier to restrict sensitive functions (endAuction, emergencyWithdraw).

Implemented minimum bid increment percentage (5%).

Auction end time extends by 10 minutes if a bid is placed near the auction close.

Stored bid history per bidder.

Added partial refund mechanism allowing bidders to withdraw overbid amounts at any time.

Commission of 2% is deducted and sent to the owner upon finalizing the auction.

Included emergency withdrawal by owner for any leftover ETH after auction finalization.

Added comprehensive revert error messages for clarity ("notOwner", "ended", "lowBid", "noRefund", etc.).

Optimized refunds loop for all losing bidders during endAuction.

Contract is designed for academic use and does not transfer physical goods.

👤 Author
Pablo Maestu
