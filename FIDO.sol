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
        addReleaseRecipient(0x9Dafc698200B9Bb509612ae39f007855d1c26B3D, 605);
        addReleaseRecipient(0xAf9736eC4814a2947B7B64354c612A41Be518b9f, 110); 
        addReleaseRecipient(0x6fc89Ac788A31880f020AabA39dB49e05D803670, 100);
        addReleaseRecipient(0x6B8A58B626dE1Aa35b9E24d4e9012E33d7084CD5, 100); // 1%
        addReleaseRecipient(0xeb8d2AC91A66b8A7790c808a5B172E647a81103a, 60);
        addReleaseRecipient(0x90d5111f4C736Ac4A0B0f90589149cD25A894537, 57);
        addReleaseRecipient(0xF3DFAcED2aE482473BEC9Ab00863C51B132e8169, 50);
        addReleaseRecipient(0x78CfF87757fbE3a18a23d28A3Ad216b5F1d26a7F, 40);
        addReleaseRecipient(0xC6D294310A8D9946c458dD886A51EFA3DA04593f, 40);
        addReleaseRecipient(0x6CA91d3f8675D83bBEf4bb3C522CF75b1B4AAD1C, 40);
        addReleaseRecipient(0xA73558c94cBDB42eF189E68C9D993D252f6F252B, 40);
        addReleaseRecipient(0xE9088899D6b8b1082A051d6bC06AD2B6e7AECe31, 40);
        addReleaseRecipient(0xf6c062b71344650e0A23Ff7D10e00842147e5e21, 30);
        addReleaseRecipient(0xf1c0091B3eFEC6e621E285b6a980734b9C437b85, 30);
        addReleaseRecipient(0x3Fc3f768c5eDC881690b33292F499964917b8189, 30);
        addReleaseRecipient(0x71192f0df65a58982fFA4e413296389f98c853B7, 20);
        addReleaseRecipient(0xf0f9b88B3e66D61469DB584712B52372C1e55E69, 15);
        addReleaseRecipient(0xeb84d5762ba1A68c3d0723518D12Ad417Df49363, 15);
        addReleaseRecipient(0xB2c04a3B20B5a498bcAE1576900A000971EDb6Dd, 10);
        addReleaseRecipient(0x52abb7EC70685b0C484F3fbc20Cce473A6c00dD3, 10);
        addReleaseRecipient(0x1cBb40e2137741Dbf6A1aFc1fa0a95fB1016b30f, 10);
        addReleaseRecipient(0xBe19c8eCf41a3F38664827C89aAD87f16dF3De38, 10);
        addReleaseRecipient(0x1F6361D690789761035585338826E4F89cbA9a44, 10); // 0.1%
        addReleaseRecipient(0xe674816FD0C0e4062B7e43dC72c34cb3023fB825, 10);
        addReleaseRecipient(0x6924F8E39623a1f5aA776637d2008Ad1c4e16598, 5);
        addReleaseRecipient(0x979cAE9260C799E73cd320936b5c5A902D291636, 5);
        addReleaseRecipient(0x7Facf41272d5a8c490Cb79CfE84981169259d935, 5);
        addReleaseRecipient(0x0299386481015Ce66FC3818DE9E7d5302FFf5278, 3);
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
