# MonteRand

"./Binpatcher" "Current/Payload/System/Library/Kernels/kernel" "kernel" '
symbol _work_interval_port_type_render_server
forward 0x0fc7f173fb21f139d173f589c9488b94cdd0fdffff
write 0x31c9909090
symbol _panic_with_thread_context
forward 0x0fc7f273fb83e20f83fa0777f30fb73441
write 0x31d2909090'

# TODO: figure out how to properly rebuild BaseSystem KC
"./Binpatcher" "Current/Zip/AssetData/boot/System/Library/KernelCollections/BootKernelExtensions.kc" "BootKernelExtensions.kc" '
forward 0x0fc7f173fb21f139d173f589c9488b94cdd0fdffff
write 0x31c9909090
set 0x0
forward 0x0fc7f273fb83e20f83fa0777f30fb73441
write 0x31d2909090'