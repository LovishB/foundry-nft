# BasicNft Smart Contract

A Solidity smart contract for creating and managing a basic NFT (Non-Fungible Token) collection with fixed-price sales functionality.

## Features

- ERC721 compliant NFT implementation
- Fixed price sales mechanism
- Minting functionality for collection owner
- Simple buying mechanism for users

## Contract Overview

The `BasicNft` contract inherits from:
- `ERC721URIStorage`: Provides NFT storage and metadata functionality
- `Ownable`: Manages contract ownership and access control

## Core Functionality

### For Collection Owner

1. **Minting NFTs**
   - Function: `mintNFT(string memory tokenURI)`
   - Only the contract owner can mint new NFTs
   - Each NFT is automatically listed for sale upon minting
   - Emits an `NFTMinted` event with owner address, token ID, and URI

2. **Setting NFT Price**
   - Function: `setPrice(uint256 _nftPrice)`
   - Allows owner to update the fixed price for all NFTs in the collection
   - Only the contract owner can modify the price

3. **Receiving Payments**
   - Automatically receives ETH when NFTs are sold
   - Payments are instantly transferred to the owner's address

### For Buyers

1. **Purchasing NFTs**
   - Function: `buyNFT(uint256 _tokenId)`
   - Users can purchase available NFTs by sending the required ETH
   - Automatically transfers both the NFT and payment
   - Emits an `NFTSold` event upon successful purchase

### View Functions

1. **Total Supply**
   - Function: `totalSupply()`
   - Returns the total number of NFTs minted in the collection

2. **Token Sale Status**
   - Variable: `s_tokenForSale`
   - Public mapping to check if a specific token is available for sale

## Error Handling

The contract includes custom error messages for common failure scenarios:

1. `TokenNotForSale`: Triggered when attempting to buy an NFT that's not for sale
2. `InsufficientFunds`: Triggered when sent ETH is less than the NFT price
3. `TransferFailed`: Triggered if the ETH transfer to the owner fails

## Events

1. `NFTMinted(address indexed owner, uint256 indexed tokenId, string tokenURI)`
   - Emitted when a new NFT is minted

2. `NFTSold(address indexed seller, address indexed buyer, uint256 indexed tokenId, uint256 price)`
   - Emitted when an NFT is successfully sold

## Contract Deployment

When deploying the contract, you need to provide:
1. Collection name
2. Collection symbol
3. Initial NFT price in wei

## Security Features

1. Ownership control via OpenZeppelin's `Ownable`
2. Safe transfer mechanisms using `_safeMint`
3. Proper access control for administrative functions
4. Checks-Effects-Interactions pattern for ETH transfers

## License

This contract is licensed under MIT.

## Dependencies

- OpenZeppelin Contracts v4.x:
  - ERC721
  - ERC721URIStorage
  - Ownable