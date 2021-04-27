// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

import "./ERC20/ERC20.sol";
import "./ERC20/ERC20Burnable.sol";
import "./ERC20/ERC20Mintable.sol";
import "./ERC20/ERC20Pausable.sol";
import "./Ownable.sol";

contract MFIL is ERC20Mintable, ERC20Burnable, Ownable {
    address public operator;

    event OperatorshipTransferred(
        address indexed previousOperator,
        address indexed newOperator
    );

    constructor(address _operator)
        ERC20("Mirror FileCoin", "MFIL")
        Pausable()
        Ownable()
    {
        operator = _operator;
        emit OperatorshipTransferred(address(0), operator);
        _setupDecimals(18);
    }

    modifier onlyOperator() {
        require(
            _msgSender() == operator,
            "Operable: caller is not the operator"
        );
        _;
    }

    function transferOperatorship(address newOperator) external onlyOwner {
        require(
            newOperator != address(0),
            "Operable: new operator is the zero address"
        );
        emit OperatorshipTransferred(operator, newOperator);
        operator = newOperator;
    }

    function pause() external onlyOperator {
        _pause();
    }

    function unPause() external onlyOperator {
        _unpause();
    }

    function addMinter(address minter) external onlyOperator {
        _addMinter(minter);
    }

    function removeMinter(address minter) external onlyOperator {
        _removeMinter(minter);
    }
}
