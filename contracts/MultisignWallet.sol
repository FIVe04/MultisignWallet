// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MultisignWallet {

    enum TransactionStatus {
        Pending,
        Confirmed,
        Executed,
        Cancelled
    }

    struct Transaction {
        address receiver;
        uint256 amount;
        TransactionStatus status;
        mapping(address => bool) ownersSigned;
        uint256 totalSigns;
    }

    uint256 public balance;
    address[] public owners;
    Transaction[] public transactionsList;
    mapping(address => bool) isOwner;

    event OwnerAdded(address indexed newOwner);
    event TransactionCreated(uint256 indexed transactionId, address indexed receiver, uint256 amount);
    event TransactionConfirmed(uint256 indexed transactionId, address indexed owner);
    event TransactionExecuted(uint256 indexed transactionId);
    event TransactionCancelled(uint256 indexed transactionId);

    constructor() {
        isOwner[msg.sender] = true;
        owners.push(msg.sender); // добавляем создателя контракта как владельца
    }

    modifier OnlyOwners {
        require(isOwner[msg.sender], "You must be an owner!");
        _;
    }

    modifier HasSufficientBalance(uint256 _amount) {
        require(balance >= _amount, "Insufficient balance!");
        _;
    }

    modifier TransactionExists(uint256 _transactionId) {
        require(_transactionId < transactionsList.length, "Transaction does not exist!");
        _;
    }

    modifier NotExecutedOrCancelled(uint256 _transactionId) {
        Transaction storage txn = transactionsList[_transactionId];
        require(txn.status != TransactionStatus.Executed, "Transaction already executed!");
        require(txn.status != TransactionStatus.Cancelled, "Transaction already cancelled!");
        _;
    }

    function addOwner(address newOwner) public OnlyOwners {
        require(!isOwner[newOwner], "Address is already an owner!");
        isOwner[newOwner] = true;
        owners.push(newOwner);
        emit OwnerAdded(newOwner);
    }

    function _mint(uint256 _amount) public OnlyOwners {
        balance += _amount;
    }

    function createTransaction(address _receiver, uint256 _amount) public
        OnlyOwners
        HasSufficientBalance(_amount)
    {
        Transaction storage newTransaction = transactionsList.push();
        newTransaction.receiver = _receiver;
        newTransaction.amount = _amount;
        newTransaction.status = TransactionStatus.Pending;
        newTransaction.totalSigns = 1;
        newTransaction.ownersSigned[msg.sender] = true;

        emit TransactionCreated(transactionsList.length - 1, _receiver, _amount);
    }

    function confirmTransaction(uint256 _transactionId) public OnlyOwners
        TransactionExists(_transactionId)
        NotExecutedOrCancelled(_transactionId)
    {
        Transaction storage currentTransaction = transactionsList[_transactionId];

        require(!currentTransaction.ownersSigned[msg.sender], "You have already signed this transaction!");

        currentTransaction.ownersSigned[msg.sender] = true;
        currentTransaction.totalSigns++;

        uint256 requiredSigns = owners.length / 2 + (owners.length % 2 == 0 ? 1 : 0);

        emit TransactionConfirmed(_transactionId, msg.sender);

        if (currentTransaction.totalSigns >= requiredSigns) {
            currentTransaction.status = TransactionStatus.Confirmed;
        }
    }

    function executeTransaction(uint256 _transactionId) payable public OnlyOwners
        TransactionExists(_transactionId)
        NotExecutedOrCancelled(_transactionId)
    {
        Transaction storage currentTransaction = transactionsList[_transactionId];

        require(currentTransaction.status == TransactionStatus.Confirmed, "Transaction is not confirmed!");
        require(balance >= currentTransaction.amount, "Insufficient balance!");

        balance -= currentTransaction.amount;
        payable(currentTransaction.receiver).transfer(currentTransaction.amount);

        currentTransaction.status = TransactionStatus.Executed;

        emit TransactionExecuted(_transactionId);
    }

    function cancelTransaction(uint256 _transactionId) public OnlyOwners
        TransactionExists(_transactionId)
        NotExecutedOrCancelled(_transactionId)
    {
        Transaction storage currentTransaction = transactionsList[_transactionId];
        currentTransaction.status = TransactionStatus.Cancelled;

        emit TransactionCancelled(_transactionId);
    }

    function getTransactionSignatures(uint256 _transactionId) public view returns (uint256) {
        return transactionsList[_transactionId].totalSigns;
    }
}
