// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

import "./ERC20/ERC20.sol";
import "./ERC20/ERC20Burnable.sol";
import "./ERC20/ERC20Mintable.sol";
import "./Ownable.sol";

contract FIDO is ERC20Mintable, ERC20Burnable, Ownable {
    using SafeMath for uint256;

    address public operator;

    uint256 private _cap = 210000000 * 10**18;
    uint256 public shareRateDecimal = 4; // 10000
    uint8 public totalReleaseWeek = 25;
    uint8 public releasedWeek = 0;
    uint256 public lastRealeaseTime = 0;
    address[] public releaseRecipient;
    mapping(address => uint256) public releaseShareRate;
    event Release(uint256 timestamp, uint8 releaseCount);
    event OperatorshipTransferred(
        address indexed previousOperator,
        address indexed newOperator
    );

    constructor(address _operator) ERC20("FIDO", "FIDO") Pausable() Ownable() {
        operator = _operator;
        emit OperatorshipTransferred(address(0), operator);
        _setupDecimals(18);
	addReleaseRecipient(0x0000000000000000000000000000000000000000, 100); // 1%
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

    function addReleaseRecipient(address recipient, uint256 shareRate)
        internal
    {
        require(releaseShareRate[recipient] == 0, "already a releaseRecipient");
        releaseRecipient.push(recipient);
        releaseShareRate[recipient] = shareRate;
    }

    function releaseShare() external onlyOperator() {
        require(
            block.timestamp - lastRealeaseTime > 1 weeks,
            "FIDO: see you next week"
        );
        require(
            releasedWeek < totalReleaseWeek,
            "FIDO: no share needs to release"
        );
        uint256 amount;
        for (uint256 index = 0; index < releaseRecipient.length; index++) {
            amount = releaseShareRate[releaseRecipient[index]]
                .mul(_cap)
                .div(10**shareRateDecimal)
                .div(totalReleaseWeek);
            _mint(releaseRecipient[index], amount);
        }
        releasedWeek += 1;
        lastRealeaseTime = block.timestamp;
        emit Release(block.timestamp, releasedWeek);
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
