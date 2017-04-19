# Transaction and logging on NVM

##  Failure-Atomic Persistent Memory Updates via JUSTDO Logging, ASPLOS'16
- 4
- An interesting one. Kind of based on Atlas (OOPSLA'14).
- They designed a new way to do logging (therefore a different way for
applications to do failure-atomic sections). Instead of providing generic
transaction interfaces like NV-heaps or Mnemosyne, JUSTDO (and Atlas) assume
application use `mutex-locks` to modify the shared data in PM.
- Of course, to provide failure-atomic sections (FASEs), NV-heaps, Mnemosyne,
JUSTDO and Atlas they all have logs. The most significant difference is the way
how _`isolation`_ is provided. For NV-heaps and Mnemosyne, isolation is
provided by their ACID transactions. For JUSTDO and Atlas, isolation has to be
provided or expressed by mutex-locks.
- NV-heaps uses UNDO, Mnemosyne uses REDO. Paper proposes a new logging
way as JUSTDO log. The key insight behind their approach is that mutex-based
critical sections are intended to execute to completion; unlike optimistic
transactions (from NV-heaps), they do not abort due to conflict. While it is
possible to implement rollback for lock-based FASEs, they propose to simply
_resume_ FASEs following failure and execute them to completion.
- Hence the JUSTDO logging, unlike UNDO or REDO, does not discard changes.
Instead, it resumes execution of each interrupted FASE at its _last STORE
instruction_. So now you can image the JUSTDO log just consists of: 1) the
destination of the STORE, 2) the value to be placed at destination and 3) the
PC.
- Personally, I do not think this mutex-based way is practical because it is
hard for programmers to code bug-free. And JUSTDO is built based on
mutex-based critical section way, hence JUSTDO is novel but not practical.

## NVWAL: Exploiting NVRAM in Write-Ahead-Logging, ASPLOS'16
- 4
- They designed a WAL system using PM for SQLite.
- In SQLite WQL mode, the dirty pages are appended to a separate log file and
the original pages remain intact in the database file. In WAL mode, the
checkpointing process periodically batches the dirty pages in the log to the
database file. WAL needs fewer `fsync()` call as it modifies a single log file
instead of two, i.e., a database file and a rollback journal file.

## High performance transactions for persistent memories, ASPLOS'16
- 5
- This paper teaches us how to implement efficient transaction systems on
different persistency models. Since different persistency models have different
ordering constraints, the transaction design can be optimized for each model.
- They are not implementing a specific transaction system. They are teaching us
how to design an efficient one. They are the first to explore implications of
various persistency models on transaction software.
- A very good paper, honestly. Hats off.

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
- 3
- Kamino-TX maintains an additional copy of data off the critical path of
transactions. Traditional transactions for NVM will implement UNDO or REDO log,
this means the tx system will have to make a copy of data first. Well, this
paper trade storage for latency, they make `an additional copy of the whole
heap`. Thus transaction can update in-place, the tx_commit will sync these two
copies.
- A little novel but not significant.

## Scalable logging through emerging non-volatile memory, VLDB'14
- TODO

##  Let's talk about storage and recovery methods for non-volatile memory database systems, SIGMOD'15
- TODO
