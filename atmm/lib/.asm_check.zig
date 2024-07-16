const atmm = @import("atmm.zig");
const Word = atmm.Word;
const arch = atmm.arch;

const SyscallResult = extern struct {
	value: Word,
	code: Word,
};

export fn syscallSyscall0(number: Word) SyscallResult {
	const r = arch.syscallSyscall(number, .{});
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallSyscall1(number: Word, arg0: Word) SyscallResult {
	const r = arch.syscallSyscall(number, .{ arg0 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallSyscall2(number: Word, arg0: Word, arg1: Word) SyscallResult {
	const r = arch.syscallSyscall(number, .{ arg0, arg1 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallSyscall3(number: Word, arg0: Word, arg1: Word, arg2: Word) SyscallResult {
	const r = arch.syscallSyscall(number, .{ arg0, arg1, arg2 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallSyscall4(number: Word, arg0: Word, arg1: Word, arg2: Word, arg3: Word) SyscallResult {
	const r = arch.syscallSyscall(number, .{ arg0, arg1, arg2, arg3 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallSysenter0(number: Word) SyscallResult {
	const r = arch.syscallSysenter(number, .{});
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallSysenter1(number: Word, arg0: Word) SyscallResult {
	const r = arch.syscallSysenter(number, .{ arg0 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallSysenter2(number: Word, arg0: Word, arg1: Word) SyscallResult {
	const r = arch.syscallSysenter(number, .{ arg0, arg1 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallSysenter3(number: Word, arg0: Word, arg1: Word, arg2: Word) SyscallResult {
	const r = arch.syscallSysenter(number, .{ arg0, arg1, arg2 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallSysenter4(number: Word, arg0: Word, arg1: Word, arg2: Word, arg3: Word) SyscallResult {
	const r = arch.syscallSysenter(number, .{ arg0, arg1, arg2, arg3 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallIntDa0(number: Word) SyscallResult {
	const r = arch.syscallIntDa(number, .{});
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallIntDa1(number: Word, arg0: Word) SyscallResult {
	const r = arch.syscallIntDa(number, .{ arg0 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallIntDa2(number: Word, arg0: Word, arg1: Word) SyscallResult {
	const r = arch.syscallIntDa(number, .{ arg0, arg1 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallIntDa3(number: Word, arg0: Word, arg1: Word, arg2: Word) SyscallResult {
	const r = arch.syscallIntDa(number, .{ arg0, arg1, arg2 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallIntDa4(number: Word, arg0: Word, arg1: Word, arg2: Word, arg3: Word) SyscallResult {
	const r = arch.syscallIntDa(number, .{ arg0, arg1, arg2, arg3 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallIntDb0(number: Word) SyscallResult {
	const r = arch.syscallIntDb(number, .{});
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallIntDb1(number: Word, arg0: Word) SyscallResult {
	const r = arch.syscallIntDb(number, .{ arg0 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallIntDb2(number: Word, arg0: Word, arg1: Word) SyscallResult {
	const r = arch.syscallIntDb(number, .{ arg0, arg1 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallIntDb3(number: Word, arg0: Word, arg1: Word, arg2: Word) SyscallResult {
	const r = arch.syscallIntDb(number, .{ arg0, arg1, arg2 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}

export fn syscallIntDb4(number: Word, arg0: Word, arg1: Word, arg2: Word, arg3: Word) SyscallResult {
	const r = arch.syscallIntDb(number, .{ arg0, arg1, arg2, arg3 });
	return .{ .value = r.value, .code = @intFromEnum(r.code) };
}
