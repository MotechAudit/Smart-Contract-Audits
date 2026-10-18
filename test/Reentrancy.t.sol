// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../security-examples/reentrancy/VulnerableVault.sol";
import "../security-examples/reentrancy/FixedVault.sol";

contract ReentrancyAttacker {
    VulnerableVault public vulnerableVault;
    FixedVault public fixedVault;
    uint256 public immutable attackAmount;
    bool public attackVulnerable;

    constructor(VulnerableVault _vulnerableVault, FixedVault _fixedVault, uint256 _attackAmount) {
        vulnerableVault = _vulnerableVault;
        fixedVault = _fixedVault;
        attackAmount = _attackAmount;
    }

    function attackVulnerableVault() external {
        attackVulnerable = true;
        vulnerableVault.deposit{value: attackAmount}();
        vulnerableVault.withdraw();
        attackVulnerable = false;
    }

    function attackFixedVault() external {
        attackVulnerable = false;
        fixedVault.deposit{value: attackAmount}();
        fixedVault.withdraw();
    }

    receive() external payable {
        if (attackVulnerable && address(vulnerableVault).balance >= attackAmount) {
            vulnerableVault.withdraw();
        } else if (!attackVulnerable) {
            // The fixed vault clears the recorded balance before this callback.
            // Catch the expected re-entry failure so the original withdrawal can finish.
            try fixedVault.withdraw() {} catch {}
        }
    }
}

contract ReentrancyTest is Test {
    uint256 private constant UNIT = 1 ether;

    function testVulnerableVaultCanBeDrainedByReentrancy() public {
        VulnerableVault vault = new VulnerableVault();
        FixedVault unusedFixedVault = new FixedVault();
        ReentrancyAttacker attacker = new ReentrancyAttacker(vault, unusedFixedVault, UNIT);

        vm.deal(address(this), 20 * UNIT);
        vault.deposit{value: 10 * UNIT}();

        attacker.attackVulnerableVault();

        assertEq(address(vault).balance, 0, "vulnerable vault should be drained");
        assertEq(address(attacker).balance, 11 * UNIT, "attacker receives vault funds plus deposit");
    }

    function testFixedVaultPreventsRepeatedWithdrawalOfSameBalance() public {
        VulnerableVault unusedVulnerableVault = new VulnerableVault();
        FixedVault vault = new FixedVault();
        ReentrancyAttacker attacker = new ReentrancyAttacker(unusedVulnerableVault, vault, UNIT);

        vm.deal(address(this), 20 * UNIT);
        vault.deposit{value: 10 * UNIT}();

        attacker.attackFixedVault();

        assertEq(address(vault).balance, 10 * UNIT, "fixed vault should retain other users' funds");
        assertEq(address(attacker).balance, UNIT, "attacker should receive only its deposit");
        assertEq(vault.balances(address(attacker)), 0, "withdrawn balance should be cleared");
    }
}
