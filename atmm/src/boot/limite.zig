inline fn request_id(id: [2]u64) [4]u64 {
	return .{ 0xc7b1dd30df4c8b88, 0x0a82e883a194f07b, id[0], id[1] };
}
