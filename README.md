# 🧾 Auction Smart Contract

This project implements a basic auction system as a smart contract using Solidity, designed as a final project for Module 2 of the blockchain course. The contract was deployed on the Sepolia testnet and includes all required and advanced functionalities.

---

## 📍 Contract Information

- **Network**: Sepolia Testnet  
- **Deployer Address**: `0xEe03460409Ba53b6dcd65E8f0B93EC296F995eb0`  
- **Verified Contract URL**: *[https://sepolia.etherscan.io/address/0xEe03460409Ba53b6dcd65E8f0B93EC296F995eb0#code]*  
- **GitHub Repository**: https://github.com/pablomaes/auction-smart-contract

---

## ⚙️ Constructor

Initializes the auction with:
- A start and end time (in seconds)
- An initial reserve price


constructor(uint _durationInMinutes, uint _reservePrice)

📢 Main Functionalities
🛎️ placeBid()
Allows participants to place a bid.

The bid must be:

Higher than the current highest bid.

At least 5% greater than the current highest bid.

If a bid is placed within the last 10 minutes of the auction, the auction end time is extended by 10 minutes.

Emits the NewBid event.

🧾 getBids()
Returns all the bidders and their respective amounts.

function getBids() public view returns (address[] memory, uint[] memory)
👑 getWinner()
Returns the address of the winner and the winning bid amount. Can only be called after the auction ends.

function getWinner() public view returns (address, uint)

💸 finalizeAuction()
Transfers the funds to the owner (minus a 2% commission).

Returns the funds to all non-winning bidders.

Can only be called once after the auction ends.

Emits the AuctionEnded event.

🔁 withdrawPartialRefund()
Allows a user to withdraw their earlier bids that are no longer valid (i.e., were overbid).

Can be called at any time.

Reverts if there is no refundable balance.

⏱️ getRemainingTime()
Returns the remaining time in seconds until the auction ends.

💰 Deposit Management
All bids are sent as ETH and stored within the contract.

Refunds are processed automatically or via withdrawPartialRefund() for overbid amounts.

📌 Events

event NewBid(address indexed bidder, uint amount);
event AuctionEnded(address winner, uint amount);

🔒 Modifiers
onlyOwner: Restricts certain functions to the contract deployer.

auctionActive: Ensures the auction has not ended.

auctionEnded: Ensures the auction has ended.

📌 Notes
The contract is for academic purposes and does not transfer any real product.

It includes secure handling of ETH and prevents reentrancy vulnerabilities.

The refund logic ensures no ETH is locked permanently.

👤 Author
Pablo Maestu