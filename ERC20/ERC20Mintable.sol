// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../Context.sol";
import "./ERC20Pausable.sol";

abstract contract ERC20Mintable is Context, ERC20Pausable {
    using SafeMath for uint256;

    mapping(address => bool) public isMinter;

    event AddMinter(address indexed minter);
    event RemoveMinter(address indexed minter);
    event Mint(
        address indexed minter,
        address indexed recipient,
        uint256 amount
    );

    modifier onlyMinter() {
        require(isMinter[_msgSender()], "ERC20: sender is not minter");
        _;
    }

    function _addMinter(address minter) internal {
        require(!isMinter[minter], "ERC20: already a minter");
        isMinter[minter] = true;
        emit AddMinter(minter);
    }

    function _removeMinter(address minter) internal {
        require(isMinter[minter], "ERC20: not a minter");
        isMinter[minter] = false;
        emit RemoveMinter(minter);
    }

    function mint(address recipient, uint256 amount) external onlyMinter {
        _mint(recipient, amount);
        emit Mint(_msgSender(), recipient, amount);
    }
}
