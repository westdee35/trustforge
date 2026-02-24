# TrustForge

A non-transferable on-chain reputation engine built on Stacks (Clarity).

## Overview

TrustForge is a smart contract that enables trustless reputation management. Reputation scores are permanently tied to principal addresses and cannot be transferred, making them suitable for governance, access control, and trust-based systems.

## Features

- **Non-Transferable Reputation**: Scores are bound to principals and cannot be moved or sold
- **Issuer-Based Model**: Owner-controlled list of authorized reputation issuers
- **Adjustable Scores**: Support for both positive and negative reputation deltas
- **Score Cap**: Built-in maximum reputation limit (10,000 points) prevents inflation
- **Block Height Tracking**: All updates are timestamped with blockchain height
- **Query Functions**: Read-only access to check reputation and verify minimum thresholds

## Contract Functions

### Owner Controls
- `add-issuer(issuer: principal)` - Authorize a new reputation issuer
- `remove-issuer(issuer: principal)` - Revoke issuer authorization

### Reputation Management
- `adjust-reputation(user: principal, delta: int)` - Adjust user reputation (issuer only)

### Read-Only Queries
- `get-reputation(user: principal)` - Retrieve user's reputation score and update timestamp
- `has-min-reputation?(user: principal, required: uint)` - Check if user meets minimum threshold
- `is-issuer?(who: principal)` - Verify if principal is an authorized issuer

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 15001 | ERR-NOT-AUTHORIZED | Only contract owner can perform this action |
| 15002 | ERR-NOT-ISSUER | Caller is not an authorized issuer |
| 15003 | ERR-INVALID-AMOUNT | Score exceeds maximum limit or invalid delta |

## Usage Example

```clarity
;; Owner adds an issuer
(add-issuer 'SP1234567890ABCDEF)

;; Issuer adjusts reputation
(adjust-reputation 'SPUSER1234567890 +100)

;; Query reputation
(get-reputation 'SPUSER1234567890)

;; Verify minimum threshold
(has-min-reputation? 'SPUSER1234567890 u50)
