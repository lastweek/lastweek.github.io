# Security

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Dec 27, 2020| Updated|
	|Dec 26, 2020| Created|

So today (Dec 26, 2020)
I'm trying to write some crypto functions to encrypt/decrypt packets,
mainly for a research project I'm doing.
Then I realize my knowledge about network security is just too shallow!
Although I know AES, SHA etc to some extent,
I'm not really sure how they are used and which one to use.

I'm trying to implement them for FPGA using SpinalHDL.

## Learn

Some basic concepts:

- https://csrc.nist.gov/projects/cryptographic-standards-and-guidelines/example-values#aHashing
- https://en.wikipedia.org/wiki/Cryptographic_hash_function
    - MD5
    - [SHA-1 SHA-2 SHA-3](https://en.wikipedia.org/wiki/Secure_Hash_Algorithms)
    - https://en.wikipedia.org/wiki/Avalanche_effect
- https://en.wikipedia.org/wiki/Public-key_cryptography
    - https://en.wikipedia.org/wiki/PKCS_1
    - [AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard)
    - [Twofish, 128-bit block plaintext -> ciphertext](https://en.wikipedia.org/wiki/Twofish)

- SSH forgos a similar process as SSL/TLS. [Understanding the SSH Encryption and Connection Process](https://www.digitalocean.com/community/tutorials/understanding-the-ssh-encryption-and-connection-process).
- [SSL/TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security)
    - [Cipher Suite](https://en.wikipedia.org/wiki/Cipher_suite)
    - [OpenSSL](https://www.openssl.org/), LibreSSL
    - So TLS (or DTLS for UDP) has a handshake process after a TCP or UDP port is open.
      This handshake process uses asymmetric-keys (public/private) keys to exchange info (e.g., choose TLS info, send pub key etc).
      They will reach a consensus on which TLS version to use, which cipher suite to use, which session key, or encryption key to use.
      Finally they will start sending traffic using symmetric encryption (e.g., AES).
      In addition, they will use secure hashing (e.g., SHA3) to ensure the integrity of the packets.

### AES Related

As I know it, it two variables controlling its variations:
1) key size, 128-bit, 192-bit, 256-bit.
2) mode of chaining, e.g., ctr, cbc.

It is a block cipher. It operates on 128-bit data, and produces 128-bit encrypted data.

- [Block cipher](https://en.wikipedia.org/wiki/Block_cipher)
- [Block cipher mode of operation](https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation)
- [Block size (cryptography)](https://en.wikipedia.org/wiki/Block_size_(cryptography))

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

SHA-3 has several variations, depending the hash size: `SHA3-224, SHA3-256, SHA3-384, and SHA3-512`.

- https://keccak.team/index.html
- https://csrc.nist.gov/projects/hash-functions

## Software

- [OpenSSL](https://www.openssl.org/) - libcrypto
    - their arch page is really good: https://www.openssl.org/docs/OpenSSLStrategicArchitecture.html
    - [OpenSSL 3.0.0 Design](https://www.openssl.org/docs/OpenSSL300Design.html)
- [OpenSSH](https://github.com/openssh/openssh-portable) - ssh/sshd/scp/etc

## Hardware

### FPGA

- [Opencore SHA-3](https://opencores.org/projects/sha3)
- [Opencore AES](https://opencores.org/projects/tiny_aes)
- [SpninalCrypto](https://github.com/SpinalHDL/SpinalCrypto)

### ASIC

- CPU has extended instructions to accelerate AES and its friends: [AES inst set](https://en.wikipedia.org/wiki/AES_instruction_set)
