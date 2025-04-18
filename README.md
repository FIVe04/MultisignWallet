# 🔐 MultisignWallet – A Secure Multi-Signature Wallet in Solidity

![License](https://img.shields.io/badge/license-MIT-green)
![Solidity Version](https://img.shields.io/badge/solidity-^0.8.0-blue)
![Build Status](https://img.shields.io/badge/build-passing-brightgreen)

## 📌 Overview

**MultisignWallet** is a smart contract built with Solidity that enables multiple trusted owners to manage and execute transactions in a secure and decentralized way. Transactions require confirmation from multiple owners before execution, adding an extra layer of safety and trust.

Designed with clarity, gas efficiency, and security in mind.

---

## 🧠 Key Features

- ✅ Multi-signature authorization
- ✅ Transaction lifecycle management: Pending → Confirmed → Executed / Cancelled
- ✅ On-chain minting for internal balance (testing)
- ✅ Dynamic ownership management
- ✅ Event-driven tracking for off-chain integration

---

## 📂 Contract Structure

### 🔸 `Transaction` Struct

```solidity
struct Transaction {
    address receiver;
    uint256 amount;
    TransactionStatus status;
    mapping(address => bool) ownersSigned;
    uint256 totalSigns;
}
```

### 🔸 Transaction Status Enum

```solidity
enum TransactionStatus {
    Pending,
    Confirmed,
    Executed,
    Cancelled
}
```

---

## 🛠 Functions Overview

### 🏗 Constructor

- Adds the contract creator as the first wallet owner.

### 👥 Ownership Management

- `addOwner(address newOwner)` – Adds a new trusted owner.

### 💰 Wallet Balance (Internal)

- `_mint(uint256 amount)` – Mints funds to the wallet for testing purposes.

### 📤 Transaction Flow

- `createTransaction(address receiver, uint256 amount)`
- `confirmTransaction(uint256 transactionId)`
- `executeTransaction(uint256 transactionId)`
- `cancelTransaction(uint256 transactionId)`

### 📈 Helper

- `getTransactionSignatures(uint256 transactionId)` – Returns how many owners have confirmed the transaction.

---

## 🔐 Security Considerations

- Only registered owners can initiate, confirm, cancel or execute transactions.
- Execution is gated by majority confirmation:  
  `totalSigns >= ceil(owners.length / 2)`
- Each transaction is uniquely confirmed per signer.

---

## 🚀 How to Use (Remix)

1. Deploy the contract in [Remix IDE](https://remix.ethereum.org).
2. Use `_mint()` to simulate balance funding.
3. Create and confirm transactions using multiple accounts.
4. Execute the transaction once enough confirmations are collected.

---

## 📸 Sample Flow

1. ✅ `Owner A` creates a transaction to send `1 ETH` to `Address X`.
2. ✅ `Owner B` confirms it.
3. ✅ Transaction becomes `Confirmed`.
4. 🔁 Any owner executes it – funds are transferred, status is updated to `Executed`.

---

## 📄 License

This project is licensed under the **MIT License**.  
Feel free to use, modify, and distribute.

---

## 🤝 Contributions

Contributions, issues, and feature requests are welcome.  
Open a pull request or create an issue!

---

## 👤 Author

Built by a Solidity developer who believes security should be **clear**, **testable**, and **multi-verified**.

> “In blockchain we trust – but signatures keep us safe.”
