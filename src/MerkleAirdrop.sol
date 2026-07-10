// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title MerkleAirdrop - one-time token claim via Merkle proof
/// @notice No admin withdrawal, no owner, no emergency recover.
contract MerkleAirdrop {
    IERC20 public immutable token;
    bytes32 public immutable merkleRoot;

    mapping(address => bool) public claimed;

    event Claimed(address indexed account, uint256 amount);

    constructor(address _token, bytes32 _merkleRoot) {
        require(_token != address(0), "zero token");
        require(_merkleRoot != bytes32(0), "zero root");
        token = IERC20(_token);
        merkleRoot = _merkleRoot;
    }

    function claim(uint256 amount, bytes32[] calldata proof) external {
        require(!claimed[msg.sender], "already claimed");

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, amount))));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "invalid proof");

        claimed[msg.sender] = true;
        require(token.transfer(msg.sender, amount), "transfer failed");
        emit Claimed(msg.sender, amount);
    }
}
