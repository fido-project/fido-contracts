// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

import "./ERC20/ERC20.sol";
import "./ERC20/ERC20Burnable.sol";
import "./ERC20/ERC20Mintable.sol";
import "./ERC20/ERC20Pausable.sol";
import "./Ownable.sol";

contract MFIL is ERC20Mintable, ERC20Burnable, Ownable {
    using SafeMath for uint256;

    address public operator;
    uint256 private _cap = 2000000000 * 10**18;

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

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - minted tokens must not cause the total supply to go over the cap.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            // When minting tokens
            require(totalSupply().add(amount) <= cap(), "ERC20: cap exceeded");
        }
    }
}
