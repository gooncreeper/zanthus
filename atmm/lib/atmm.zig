//! Library for interacting with ATMM
//! Many constants in this library are referenced internally by ATMM

const native_arch = @import("builtin").cpu.arch;

/// System word sized integer
/// Must be at least 32-bits and a power of two
pub const Word = switch(native_arch) {
	.x86 => u32,
	.x86_64 => u64,
	else => @compileError("Unsupported architecture"),
};

comptime {
	if (@bitSizeOf(Word) < @bitSizeOf(usize)) @compileError("usize cannot be larger than Word size");
}

/// Architecture specific API
pub const arch = switch(native_arch) {
	.x86 => @import("x86.zig"),
	.x86_64 => @import("x86_64.zig"),
	else => @compileError("Unsupported architecture"),
};

/// Return value of all architecture specific syscall functions
pub const SyscallResult = struct {
	value: Word,
	code: SyscallReturnCode,
};

pub const SyscallReturnCode = enum(Word) {
	/// No error
	Ok = 0,
	/// The operating system does not implement given syscall number
	BadSyscall = 1,
	/// The process does not have access to given syscall
	SyscallDenied = 2,
	/// The process or operating system is out of memory
	OutOfMemory = 3,
	/// No object corresponds to given handle number
	BadHandle = 4,
	/// Handle number allready corresponds to an object
	HandleInUse = 5,
	/// No more ObjectHandle values can be automatically allocated
	OutOfHandles = 6,
	/// No more descendents can be created from given object
	_,
	
	pub inline fn genericError(code: SyscallReturnCode) GenericError {
		@setCold(true);
		return switch(code) {
			.BadSyscall => GenericError.BadSyscall,
			else => GenericError.Unknown,
		};
	}
};

pub const GenericError = error{
	/// The operating system returned an undocumented error code
	/// This can likely be fixed by updating this library
	Unknown,
	BadSyscall,
};

pub const SyscallNumber = enum(Word) {
	/// arg0:
	syscall_many = 0,
	/// arg0: object handle
	/// ret: new object handle
	object_relocate = 1,
	/// arg0: source object handle
	/// arg1: destination object handle
	object_move = 2,
	/// arg0: object handle
	/// arg1: perms
	/// ret: new object handle
	object_reduce = 3,
	/// arg0: object handle
	object_reset = 4,
	/// arg0: object handle
	object_detach = 5,	
	/// arg0: object handle
	object_remove = 6,
	/// arg0: object handle
	object_destroy = 7,
	/// arg0: start
	/// arg1: count
	object_reserve = 8,
	/// arg0: object handle
	/// ret: object info
	object_stat = 9,
	/// New syscalls may be added which can be accessed using @intFromEnum(number) until they are
	/// defined in this library
	_,
};

/// Wrapper function around syscall to ATMM
/// All arguments must be Word sized
pub inline fn syscall(number: SyscallNumber, arguments: anytype) SyscallResult {
	inline for (arguments) |a| {
		if (@sizeOf(@TypeOf(a)) != @sizeOf(Word)) @compileError("Expected Word sized arguments");
	}
	return arch.syscall(@intFromEnum(number), arguments);
}

//pub const thread = @Import("thread.zig"): // scheduling
pub const object_space = @import("object.zig");
pub const address_space = @import
//pub const memory = @import("memory.zig");
//pub const endpoint = @import("endpoint.zig");
//swap
