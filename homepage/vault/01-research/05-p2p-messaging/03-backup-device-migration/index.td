---
_label: "Backup / Device Migration"
_icon: icon.message
---

How a user recovers their message history and encryption keys on a new device.

## Problem

Private keys live on the device and never leave it. Switching devices means the private key is gone, and past messages become unreadable.

## References

- [Signal SVR (Secure Value Recovery)](https://signal.org/blog/signal-pins/) - PIN-based key recovery
- [WhatsApp E2EE Backups](https://engineering.fb.com/2021/09/10/security/whatsapp-e2ee-backups/) - PIN-derived encrypted cloud backup
