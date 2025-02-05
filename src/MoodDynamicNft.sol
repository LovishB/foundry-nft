// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol"; //for encoding in svg in base64


contract MoodDynamicNft is ERC721URIStorage, Ownable {

    // Mood states
    enum Mood { HAPPY, SAD }

    string private s_happySvg;
    string private s_sadSvg;
    Mood private s_currentMood;

    event NFTMinted(address indexed owner, uint256 indexed tokenId);
    event MoodChanged(Mood newMood);

    constructor(
        string memory _name, 
        string memory _symbol, 
        string memory _happySvg,
        string memory _sadSvg
    ) ERC721(_name, _symbol) Ownable(msg.sender) {
        s_happySvg = _happySvg; //send svg data in base64
        s_sadSvg = _sadSvg;
        s_currentMood = Mood.HAPPY; //by default mood is happy

        //minting nft directly in constructor(since we have single NFT)
        _safeMint(msg.sender, 1);
        emit NFTMinted(msg.sender, 1);
        //TokenURI is not set as we are generating it dynamically by overridding when tokenURI function is called
    }

    /*
    * Function generates the metadata for the NFT that marketplace and wallet will read
    * uint256 param tokenId is not used since this is a single NFT
    * @dev Overriding tokenURI function and generates dynamic metadata based on mood
    */
    function tokenURI(uint256) public view override returns (string memory) {
        string memory currentMood = s_currentMood == Mood.HAPPY ? "Happy" : "Sad";
        string memory currentSvg = s_currentMood == Mood.HAPPY ? s_happySvg : s_sadSvg;
        string memory json = Base64.encode( //endoing the bytes in base64 for better readability
            abi.encodePacked( //abi.encodePacked(arg) is low level string concatenation function, output is in bytes
                '{"name": "Mood NFT", ',
                '"description": "This NFT changes its mood", ',
                '"attributes": [',
                    '{"trait_type": "Mood", "value": "', currentMood, '"}',
                '], ',
                '"image": "data:image/svg+xml;base64,', currentSvg, '"}'
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json)); //concatinating the json with data:application/json;base64,
    }


    function flipMood() external onlyOwner {
        Mood newMood = s_currentMood == Mood.HAPPY ? Mood.SAD : Mood.HAPPY;
        s_currentMood = newMood;
        emit MoodChanged(newMood);
    }

    function updateSvgs(string memory _happySvg, string memory _sadSvg) external onlyOwner {
        s_happySvg = _happySvg;
        s_sadSvg = _sadSvg;
    }

    function getCurrentMood() external view returns (Mood) {
        return s_currentMood;
    }
}