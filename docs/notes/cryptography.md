# Cryptography

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Oct 11, 2021| Add the github awesome link|
	|Jan 16, 2021| Updated|
	|Dec 27, 2020| Updated|
	|Dec 26, 2020| Created|

So today (Dec 26, 2020)
I'm trying to write some crypto functions to encrypt/decrypt network packets.
Then I realize my knowledge about network security is just too shallow.
Although I know AES, SHA etc to some extent,
I'm not really sure how to build them.

## Learning

Try this one: [awesome-cryptograghy](https://github.com/sobolevn/awesome-cryptography).

Some basic concepts:

- [cryptographic-standards-and-guidelines](https://csrc.nist.gov/projects/cryptographic-standards-and-guidelines/example-values#aHashing)
- [Cryptographic Hash Function](https://en.wikipedia.org/wiki/Cryptographic_hash_function)
    - MD5
    - [SHA-1 SHA-2 SHA-3](https://en.wikipedia.org/wiki/Secure_Hash_Algorithms)
    - https://en.wikipedia.org/wiki/Avalanche_effect
- [Public Key Cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography)
    - https://en.wikipedia.org/wiki/PKCS_1
    - [AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard)
    - [Twofish, 128-bit block plaintext -> ciphertext](https://en.wikipedia.org/wiki/Twofish)

Courses:

- [UCSE CSE207 by Prof Mihir Bellare](https://cseweb.ucsd.edu/~mihir/cse207/index.html)

## TLS and SSH

SSH has a similar process as SSL/TLS.
See [Understanding the SSH Encryption and Connection Process](https://www.digitalocean.com/community/tutorials/understanding-the-ssh-encryption-and-connection-process).

- [SSL/TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security)
    - [Cipher Suite](https://en.wikipedia.org/wiki/Cipher_suite)
    - [OpenSSL](https://www.openssl.org/), LibreSSL

So `TLS` (or `DTLS` for UDP) has an **extra** handshake protocol after a TCP or UDP port is open.
This handshake process uses asymmetric-keys (public/private) keys to exchange info (e.g., choose TLS info, send pub key etc).
They will reach a consensus on which TLS version to use, which cipher suite to use, which session key, or encryption key to use.
Finally they will start sending traffic using symmetric encryption (e.g., AES).
In addition, they will use secure hashing (e.g., SHA3) to ensure the integrity of the packets.

### AES Related

As I know it, it two variables controlling its variations:
1) key size, 128-bit, 192-bit, 256-bit => AES128, AES192, AES256
2) mode of chaining, for data that is larger than standard AES 128-bit block size.
   The modes can be CTR, CBC and so on. This is more advanced.

AES is a `block cipher`. AES operates on 128-bit data block, and produces 128-bit encrypted data.
Larger data (packets) needs to specify the mode of chaining.

- [Block cipher](https://en.wikipedia.org/wiki/Block_cipher)
- [Block cipher mode of operation](https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation)
- [Block size (cryptography)](https://en.wikipedia.org/wiki/Block_size_(cryptography))

Details

- S-Box
    - https://en.wikipedia.org/wiki/S-box
    - https://en.wikipedia.org/wiki/Rijndael_S-box

- Key Schedule, round constant
    - https://en.wikipedia.org/wiki/AES_key_schedule

!!! quote
    mode of operation describes how to repeatedly apply
    a cipher's single-block operation to securely transform
    amounts of data larger than a block

!!! quote
	Block ciphers operate on a fixed length string of bits. The length of this bit string is the block size. Both the input (plaintext) and output (ciphertext) are the same length; the output cannot be shorter than the input – this follows logically from the pigeonhole principle and the fact that the cipher must be reversible – and it is undesirable for the output to be longer than the input.

### SHA Related

SHA-3 has several variations, depending the hash size, it can be `SHA3-224, SHA3-256, SHA3-384, and SHA3-512`.

- https://keccak.team/index.html
- https://csrc.nist.gov/projects/hash-functions

## Case Studies

As usual, let us look at some real world use cases and codes.

### Software

Both of them have implemented a set of cryptographic functions, collectively called `libcrypto`.
But.. these libraries have deep roots in their projects, thus using a lot project-specific macros etc,
so I think they are not that easy to read.
There are a lot simpler POC code out there.

- [OpenSSL](https://www.openssl.org/) - libcrypto
    - their arch page is really good: https://www.openssl.org/docs/OpenSSLStrategicArchitecture.html
    - [OpenSSL 3.0.0 Design](https://www.openssl.org/docs/OpenSSL300Design.html)
- [OpenSSH](https://github.com/openssh/openssh-portable) - ssh/sshd/scp/etc
- [Linux kernel crypto API](https://www.kernel.org/doc/html/latest/crypto/index.html)

### FPGA

1. [Opencore SHA-3](https://opencores.org/projects/sha3)
2. [Opencore AES](https://opencores.org/projects/tiny_aes)
3. [SpninalCrypto](https://github.com/SpinalHDL/SpinalCrypto)
    - So I personally use this in my research project. It is clean.

### ASIC

- CPU has extended instructions to accelerate AES and its friends: [AES inst set](https://en.wikipedia.org/wiki/AES_instruction_set)
