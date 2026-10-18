# Reentrancy: Vulnerable vs. Fixed

This educational example demonstrates a common reentrancy risk in Solidity.

## Files

- `VulnerableVault.sol` — transfers ETH before updating the caller's balance.
- `FixedVault.sol` — updates the balance before making the external call, following checks-effects-interactions.

## Risk

An external call can transfer control to recipient-controlled code. If contract state is not updated first, that code may call back into the withdrawal function before the original operation finishes.

## Mitigation shown

The fixed example updates internal accounting before the external call. Production contracts may also require a reentrancy guard, careful review of all external-call paths, and automated tests tailored to the full contract.

## Important limitations

These snippets are minimal teaching examples, not production-ready vaults and not a complete security audit. They have not been presented as passing a test suite. Review the complete system, compiler configuration, dependencies, and business logic before deployment.

## Suggested validation

1. Compile both contracts with Solidity 0.8.20 or a compatible compiler.
2. Write an attacker contract that attempts to re-enter `withdraw()`.
3. Confirm the vulnerable example permits repeated withdrawals when sufficient vault funds exist.
4. Confirm the fixed example prevents repeated withdrawal of the same recorded balance.
5. Add regression tests and run them in CI before treating this example as verified.
