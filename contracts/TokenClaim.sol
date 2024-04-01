
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';


contract TokenClaim is ReentrancyGuard, Ownable, Pausable {
    using SafeERC20 for IERC20;

    address public signer;

    mapping(address => mapping(uint256 => bool)) public userClaimed;
    mapping(address => mapping(uint256 => uint256)) public userRoundClaimedAmount;
    mapping(address => uint256) public userClaimedAmount;

    uint256 public totalClaimed;

    address public claimToken;
    uint256 public maxClaim;


    event EventClaimed(
        address indexed recipient,
        uint256 indexed amount,
        uint256 indexed _id
    );


    event EventEmergencyWithdraw(
        address _token,
        address _to,
        uint256 _amount
    );

    constructor(address _claimToken, uint256 _maxClaim, address _signer) {
        require(_signer != address(0), '_signer Is Zero');
        require(_claimToken != address(0), '_idoToken Is Zero');

        claimToken = _claimToken;
        signer = _signer;
        maxClaim = _maxClaim;
    }

    function setSigner(address _signer) onlyOwner external {
        require(_signer != address(0), '_signer is zero address');
        signer = _signer;
    }

    function setClaimToken(address _claimToken) onlyOwner external {
        require(_claimToken != address(0), '_claimToken is zero address');
        claimToken = _claimToken;
    }


    function setMaxClaim(uint256 _maxClaim) onlyOwner external {
        maxClaim = _maxClaim;
    }

    function eWA(
        address _token,
        address _to
    ) onlyOwner external {
        if (address(this).balance > 0) {
            payable(_to).transfer(address(this).balance);
        }
        uint256 amt = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(_to, amt);
        emit EventEmergencyWithdraw(
            _token,
            _to,
            amt
        );
    }


    fallback() external {}

    receive() external payable {}

    function claim(
        uint256 _id,
        uint256 _amount,
        bytes calldata sig
    ) external whenNotPaused nonReentrant {
        require(claimToken != address(0), 'Invalid token');
        require(_amount > 0, 'Invalid amount');
        address recipient = msg.sender;
        require(!userClaimed[recipient][_id], "Claimed!");
        require(maxClaim == 0 || (maxClaim > 0 && _amount <= maxClaim), 'Invalid Claim Amount');

        uint256 thisBal = IERC20(claimToken).balanceOf(address(this));
        require(thisBal >= _amount, "Insufficient Balance");
        bytes32 message = prefixed(keccak256(abi.encodePacked(
            recipient,
            _id,
            _amount,
            address(this)
        )));

        require(recoverSigner(message, sig) == signer, 'wrong signature');

        userClaimedAmount[recipient] += _amount;
        userClaimed[recipient][_id] = true;
        userRoundClaimedAmount[recipient][_id] = _amount;
        totalClaimed += _amount;

        IERC20(claimToken).safeTransfer(recipient, _amount);

        emit EventClaimed(
            recipient,
            _amount,
            _id
        );
    }


    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            '\x19Ethereum Signed Message:\n32',
            hash
        ));
    }

    function recoverSigner(bytes32 message, bytes memory sig)
    internal
    pure
    returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig)
    internal
    pure
    returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
        // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
        // second 32 bytes
            s := mload(add(sig, 64))
        // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }
}
