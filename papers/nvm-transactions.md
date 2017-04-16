# NVM Systems and Transation Papers
Collected by `Yizhou` <shan13@purdue.edu>  
First line is a five star rating, range from [1:5]

## High performance transactions for persistent memories, ASPLOS'16
- 5
- Ensuring that persistent data is consistent despite power failures and
crashes is difficult, especially when manipulating complext data structures
with fine-grained accesses. One way to ease this difficulty is to access
persistent data through atomic, durable transactions, which make groups
of updates appear as one atomic unit with respect to failure.
- Implementing transactions on NVRAM requires the ability to constrain the
order of NVRAM writes, for example, to ensure that a transaction's log record
is completed before it is marked committed.
- Constraining the order that writes persist is essential to ensure consistency
recovery, and minimizing these constranints is key to enabling high performance.
- This paper considers how to implement NVRAM transactions in a way that minimizes
persist dependencies, to improve transaction performance.

## Scalable logging through emerging non-volatile memory, VLDB'14
