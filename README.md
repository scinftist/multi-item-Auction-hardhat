# Multi Token Auctions: Simultaneous Sales

this a new auction contract that provides a way to auction multiple Item at onece, the current state of the project is unfinish and using it is not recomended.

-   DoubleLinkedLibrary.sol is a linked list library that maintains the sorted state of the list, and have an indexing function for the finished state.
-   MToken.sol is a token that has batch minting capability after deployment.

*   MAcutionHouse.sol is the Auction library that can Auction n token in togethor and bidders bid for getting better possition "turn duration" that determines who get to choose from a pool of token in Auction
