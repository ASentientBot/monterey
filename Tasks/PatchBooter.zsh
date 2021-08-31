./Binpatcher "Current/Zip/AssetData/boot/Firmware/usr/standalone/i386/boot.efi" "ffffffff.efi" '
# and r8d,0xffef (CSR mask)
forward 0x4183e0ef

# or r8d,0xffff
write 0x4183c8ff

# test rax,rax (check result of call to get "csr-active-config")
backward 0x4885c0

# nop the subsequent jump
set +0x3
nop 0x2'