# Motech Audit — Reentrancy Test Example

A small, runnable Foundry example showing how reentrancy can affect a Solidity vault and how the checks-effects-interactions pattern mitigates the demonstrated issue.

## Files

- `security-examples/reentrancy/VulnerableVault.sol` — updates accounting after the external call.
- `security-examples/reentrancy/FixedVault.sol` — clears the recorded balance before the external call.
- `test/Reentrancy.t.sol` — exploit and regression tests.

## Run locally

Install Foundry first: https://getfoundry.sh/

From the repository root, install the test library and run the tests:

```bash
forge install foundry-rs/forge-std
forge test -vv
```

The tests demonstrate that the vulnerable example can be drained by the included attacker contract, while the fixed example prevents repeated withdrawal of the same recorded balance.

## Scope and limitations

This is an educational proof of concept, not a production vault or a complete audit. The fixed example demonstrates one mitigation pattern only. Real contracts need review of all external-call paths, dependencies, access controls, accounting invariants, and deployment configuration. Passing these tests does not prove a contract is secure.
