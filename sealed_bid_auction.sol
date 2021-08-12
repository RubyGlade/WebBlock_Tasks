// This is the contract for the sealed-bid auction of an ERC-20 token
//We'll be using hashes for submitting the bids of each person. One bidder can not see the bid of another person.
//After the bidding time, all the bids will be revealed, and the highest bidder will get the whole token stash for the entire price.

pragma solidity ^0.4.21;

import "./ierc20token.sol";

contract SealedBidAuction {
    address seller;

    IERC20Token public token;
    uint256 public reservePrice;
    uint256 public endOfBidding;
    uint256 public endOfRevealing;

    //function to create an auction for the token
    function SealedBidAuction(
        IERC20Token _token,
        uint256 _reservePrice,
        uint256 biddingPeriod,
        uint256 revealingPeriod
    )
        public
    {
        token = _token;
        reservePrice = _reservePrice;

        endOfBidding = now + biddingPeriod;
        endOfRevealing = endOfBidding + revealingPeriod;

        seller = msg.sender;
    }

    //Mapping the addresses to their ETH balance, and their bid's hash
    mapping(address => uint256) public balanceOf;
    mapping(address => bytes32) public hashedBidOf;

    //Function to create a secure bid (hashed bid) 
    function bid(bytes32 hash) public payable {
        require(now < endOfBidding);

        hashedBidOf[msg.sender] = hash;
        balanceOf[msg.sender] += msg.value;
        require(balanceOf[msg.sender] >= reservePrice);
    }

    address public highBidder = msg.sender;
    uint256 public highBid;

    //After the bidding itme, the address of the highest bidder should be revealed
    function reveal(uint256 amount, uint256 nonce) public {
        require(now >= endOfBidding && now < endOfRevealing);

        require(keccak256(amount, nonce) == hashedBidOf[msg.sender]);

        require(amount >= reservePrice);
        require(amount <= balanceOf[msg.sender]);

        if (amount > highBid) {
            // return escrowed bid to previous high bidder
            balanceOf[seller] -= highBid;
            balanceOf[highBidder] += highBid;

            highBid = amount;
            highBidder = msg.sender;

            // transfer new high bid from high bidder to seller
            balanceOf[highBidder] -= highBid;
            balanceOf[seller] += highBid;
        }
    }

    function withdraw() public {
        require(now >= endOfRevealing);

        uint256 amount = balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function claim() public {
        require(now >= endOfRevealing);

        uint256 t = token.balanceOf(this);
        token.transfer(highBidder, t);
    }
}