---
_label: "E2EE"
_icon: icon.message
---

How the pieces fit together for End-to-End Encryption.

E2EE is not a single algorithm. It is the combination of:

1. [**Key Exchange**](../01-key-exchange/index) - establish a shared secret between two peers (ECDH for online, X3DH for offline).
2. [**Message Encryption**](../02-message-encryption/index) - per-message key rotation with forward secrecy (Double Ratchet).
3. [**Backup / Device Migration**](../03-backup-device-migration/index) - recovering keys and history on a new device.

## References

- [Soatok >> Going Bark: A Furry's Guide to End-to-End Encryption](https://soatok.blog/2020/11/14/going-bark-a-furrys-guide-to-end-to-end-encryption/) - full E2EE walkthrough including library choices
- [Soatok >> Towards E2EE for Direct Messages in the Fediverse](https://soatok.blog/2022/11/22/towards-end-to-end-encryption-for-direct-messages-in-the-fediverse/) - practical E2EE design with a server in the middle
- [Soatok >> E2EE for the Fediverse Update](https://soatok.blog/2024/09/13/e2ee-for-the-fediverse-update-were-going-post-quantum/) - updated version, moving to post-quantum
