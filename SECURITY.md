# Security Policy

Never commit passwords, tokens, private keys, credentials, cookies, private
certificates or secret environment values.

Hardware-specific scripts should be inspected before execution.

Kernel, initramfs and EFI changes should be treated as potentially destructive.
Verify the real boot filesystem and recovery path before modification.
