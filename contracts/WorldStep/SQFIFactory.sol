// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;
import "./FactoryStorage.sol";
import "./IERC165.sol";
import "./Ownable.sol";
import "./SQFNFT.sol";


pragma solidity ^0.8.4;

contract SQFItemFactory is FactoryStorage, Ownable

{
    address public nftContract;
    uint256 public goblinActivePrice;
    uint256 public devilActivePrice;
    uint256 public angelActivePrice;

    SQFItem public _mainToken;
    
    constructor(address _nftContract, address _tokenContract) {
        require(_nftContract != address(0), "Invalid contract address");
        _mainToken = SQFItem(_nftContract);
        sqfToken = IERC20(_tokenContract);
        nftContract = _nftContract;
        goblinActivePrice = 500*10**18;
        devilActivePrice = 1000*10**18;
        angelActivePrice = 1500*10**18;
    }

    function setSQFToken(address _address) external onlyOwner {
        sqfToken = IERC20(_address);
    }
    

    function safeMintItem(string memory itemId, string memory externalId) public { 
        require(
            userStatus[msg.sender].status != activeStatus.HUMAN,
            "You must active account before mint NFTs!"
        );
        uint256 tokenId = _mainToken.currentCountId();
        _mainToken.safeMintToUser(msg.sender,itemId,externalId);
        ingameItem[tokenId] = ingameItems(
            tokenId,
            msg.sender,
            itemId,
            externalId,
            false
        );

    }

    function setOwnerIngameItem(address from,address newOwner, uint256 tokenId) external  { 
            require(from == ingameItem[tokenId].owner, "Only owner of token can do this");
            ingameItem[tokenId].owner = newOwner;
    }

    function lockIngameItem(uint256 tokenId) public  { 
            require(msg.sender == ingameItem[tokenId].owner, "Only owner of token can do this");
            require(ingameItem[tokenId].ingame == false, "Locked item !");
            ingameItem[tokenId].ingame = true;
    }

    function unlockIngameItem(uint256 tokenId) public  { 
            require(msg.sender == ingameItem[tokenId].owner, "Only owner of token can do this");
            require(ingameItem[tokenId].ingame == true, "Unlocked item !");
            ingameItem[tokenId].ingame = false;
    }

    function getOwnItems(bool ingame) public view returns(ingameItems[] memory) { 
            uint totalItemCount = _mainToken.currentCountId();
            uint itemCount = 0;
            uint currentIndex = 0;           
            for (uint i = 0; i < totalItemCount; i++) {
                if (( ingameItem[i].owner == msg.sender) && (ingameItem[i].ingame == ingame)) {
                itemCount += 1;
                }
            }
            ingameItems[] memory items = new ingameItems[](itemCount);
            for (uint i = 0; i < totalItemCount; i++) {
            if (( ingameItem[i].owner == msg.sender) && (ingameItem[i].ingame == ingame )) {

                uint currentId = ingameItem[i].id;
                ingameItems storage currentItem = ingameItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function getIngameItem(uint itemId) public view returns (ingameItems memory) {
        ingameItems memory item = ingameItem[itemId];
        return item;
    }
     
    function activeAccount(string memory typeAccount) public { 

        require(
        keccak256(abi.encodePacked(typeAccount)) == keccak256(abi.encodePacked("0"))
        || keccak256(abi.encodePacked(typeAccount)) == keccak256(abi.encodePacked("1"))
        || keccak256(abi.encodePacked(typeAccount)) == keccak256(abi.encodePacked("2"))
        || keccak256(abi.encodePacked(typeAccount)) == keccak256(abi.encodePacked("3")),
        "Account's type is not valid"
        );
        if (keccak256(abi.encodePacked(typeAccount)) == keccak256(abi.encodePacked("1"))) {
            sqfToken.transferFrom(msg.sender, address(owner()),goblinActivePrice);
            userStatus[msg.sender] = usersStatus(
            activeStatus.GOBLIN
            );
        }
        else if(keccak256(abi.encodePacked(typeAccount)) == keccak256(abi.encodePacked("2"))) { 
            sqfToken.transferFrom(msg.sender, address(owner()),devilActivePrice);
            userStatus[msg.sender] = usersStatus(
            activeStatus.DEVIL
            );
        }
        else if(keccak256(abi.encodePacked(typeAccount)) == keccak256(abi.encodePacked("3"))) { 
            sqfToken.transferFrom(msg.sender, address(owner()),angelActivePrice);
            userStatus[msg.sender] = usersStatus(
            activeStatus.ANGEL
            );
        }
        emit ActiveAccount(msg.sender,typeAccount);
    }
}