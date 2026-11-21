# Unsorted docs
Here are just some snippets I need to remember that have not been sorted yet

### Enable TPM 2 for LUKS decrypt
```sh
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p3
```
