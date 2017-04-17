# Transaction and logging on NVM

## NVWAL: Exploiting NVRAM in Write-Ahead-Logging, ASPLOS'16
- asd

##  Failure-Atomic Persistent Memory Updates via JUSTDO Logging, ASPLOS'16
- asd

## High performance transactions for persistent memories, ASPLOS'16
- 5
- Ensuring that persistent data is consistent despite power failures and
crashes is difficult, especially when manipulating complex data structures
with fine-grained accesses. One way to ease this difficulty is to access
persistent data through atomic, durable transactions, which make groups
of updates appear as one atomic unit with respect to failure.
- Implementing transactions on NVRAM requires the ability to constrain the
order of NVRAM writes, for example, to ensure that a transaction's log record
is completed before it is marked committed.
- Constraining the order that writes persist is essential to ensure consistency
recovery, and minimizing these constraints is key to enabling high performance.
- This paper considers how to implement NVRAM transactions in a way that
minimizes persist dependencies, to improve transaction performance.

## DUDETM: Building Durable Transactions with Decoupling for Persistent Memory, ASPLOS'17
- 5
- Yet another transaction system for PM.
- This paper presents DUDETM, a crash-consistent durable transaction system
that avoids the `drawbacks of both undo logging and redo logging (check
paper)`. DUDETM uses `shadow DRAM` to decouple the execution of a durable
transaction into three fully asynchronous steps.
- A totally different approach as HighPerfXact-aspolos16.
- This paper is well written, has a very good discussion about pros and cons
to implement undo and redo logging in PM.

## Atomic In-place Updates for Non-volatile Main Memories with Kamino-Tx, EuroSys'17
- ?
- Yet another transaction system for PM.

## Scalable logging through emerging non-volatile memory, VLDB'14
- toread
