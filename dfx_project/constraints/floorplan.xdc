create_pblock pblock_u_rm
add_cells_to_pblock [get_pblocks pblock_u_rm] [get_cells -quiet [list u_rm]]
resize_pblock [get_pblocks pblock_u_rm] -add {SLICE_X52Y143:SLICE_X87Y148}
set_property SNAPPING_MODE ON [get_pblocks pblock_u_rm]
