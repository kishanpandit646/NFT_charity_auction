module NFTCharityAuction::Auction {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    struct AuctionItem has store, key {
        nft: address,    // NFT identifier or address of the NFT
        highest_bid: u64,  // Highest bid in the auction
        highest_bidder: address,  // Address of the highest bidder
        charity_address: address, // Address of the charity to receive funds
    }

    /// Function to create a new auction item.
    public fun create_auction(owner: &signer, nft: address, charity_address: address) {
        let auction_item = AuctionItem {
            nft,
            highest_bid: 0,
            highest_bidder: owner,
            charity_address,
        };
        move_to(owner, auction_item);
    }

    /// Function to place a bid on an auction item.
    public fun place_bid(bidder: &signer, auction_owner: address, amount: u64) acquires AuctionItem {
        let auction_item = borrow_global_mut<AuctionItem>(auction_owner);

        // Ensure the bid is higher than the current highest bid
        assert!(amount > auction_item.highest_bid, 100);

        // Refund the previous highest bidder
        if (auction_item.highest_bid > 0) {
            let refund = coin::withdraw<AptosCoin>(auction_item.highest_bidder, auction_item.highest_bid);
            coin::deposit<AptosCoin>(auction_item.highest_bidder, refund);
        }

        // Accept the new highest bid
        let new_bid = coin::withdraw<AptosCoin>(bidder, amount);
        coin::deposit<AptosCoin>(auction_item.charity_address, new_bid);

        // Update auction item with the new highest bid and bidder
        auction_item.highest_bid = amount;
        auction_item.highest_bidder = bidder;
    }
}
