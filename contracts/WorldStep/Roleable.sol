// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract Roleable {
    mapping (address => bool) private _minters;
    address private _minteradmin;
    address public pendingMinterAdmin;

    modifier onlyMinterAdmin() {
        require (msg.sender == _minteradmin, "caller not a minter admin");
        _;
    }
    modifier onlyMinter() {
        require (_minters[msg.sender] == true, "can't perform mint");
        _;
    }
    modifier onlyPendingMinterAdmin() {
        require(msg.sender == pendingMinterAdmin, "caller not a pending minter admin");
        _;
    }

    event MinterTransferred(address indexed previousMinter, address indexed newMinter);

    constructor () {
        _minteradmin = msg.sender;
        _minters[msg.sender] = true;
    }

    function minterAdmin() public view returns (address) {
        return _minteradmin;
    }

    function addToMinters(address account) public onlyMinterAdmin {
        _minters[account] = true;
    }

    function removeFromMinters(address account) public onlyMinterAdmin {
        _minters[account] = false;
    }

    function transferMinterAdmin(address newMinter) public onlyMinterAdmin {
        pendingMinterAdmin = newMinter;
    }

    function claimMinterAdmin() public onlyPendingMinterAdmin {
        emit MinterTransferred(_minteradmin, pendingMinterAdmin);
        _minteradmin = pendingMinterAdmin;
        pendingMinterAdmin = address(0);
    }
}