// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;


contract FactoryStorage {

    enum activeStatus {
        HUMAN,
        GOBLIN,
        DEVIL,
        ANGEL
    }

    struct activeItems {
        uint256 id;
        address owner;
        activeStatus status;
    }

    struct ingameItems { 
        uint256 id;
        address owner;
        string itemId;
        string externalId;
        bool ingame;
    }

    struct usersStatus { 
        activeStatus status;
    }

    
    bytes4 public constant ERC721_Interface = bytes4(0x80ac58cd);
    IERC20 public sqfToken;

    // From ERC721 registry assetId to Item (to avoid asset collision)
    mapping(uint256 => activeItems) public activeItem;
    mapping(uint256 => ingameItems) public ingameItem;
    mapping(address => usersStatus) public userStatus;


    event Claim(address indexed receiver, string tokenId);
    event Burn(address indexed owner, string tokenId);
    event Mint(address indexed to, string tokenId);
    event ActiveAccount(address indexed user, string status);
    event TransferToGame(address indexed owner, string tokenId);
    event UnlockToken(address indexed owner, string tokenId);

}