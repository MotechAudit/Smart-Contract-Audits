// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Educational example showing checks-effects-interactions.
/// @dev This illustrates one mitigation pattern; it is not a complete audit.
contract FixedVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        // Effect: update state before transferring control externally.
        balances[msg.sender] = 0;

        // Interaction: external call occurs only after accounting is updated.
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
