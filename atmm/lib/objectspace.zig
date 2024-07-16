//! # Objects
//! ## Description
//! * Objects are used to access system resources. They are accessed through object handles that
//! refer to object capabilities which give permissions for access to an object.
//! * Object capabilities can be reduced into other object capabilities with less or equal
//! permissions to an object. The new object capability is a child of the original.
//! ## Behavior
//! * There is no limitation on usable handle values.
//! * Object handles are local to the process they were allocated in.
//! * Ranges of handle numbers can be reserved and will not be used unless explicitly specified.
//! ** Handle numbers become no longer reserved once an object capability occupies them.
//! ## Recomendations
//! * Handle number zero should be used for refering to the current object space.

const atmm = @import("atmm.zig");
const Word = atmm.Word;
const syscall = atmm.syscall;
const GenericError = atmm.GenericError;

/// A number corresponding to an Object
/// Any other -Handle type can safely be casted to this
pub const ObjectHandle = Word;
/// A bit field correspond to an Object's permissions
/// Any other -Perms type can safely be bit casted to this
pub const ObjectPerms = u16;
/// The result of the stat syscall
pub const ObjectInfo = packed struct(u32) {
	object_type: ObjectType,
	permissions: ObjectPerms,
	reserved: u8,

	pub const ObjectType = enum(u8) {
		Process = 0,
	}
}

/// Returns ObjectHandle for other -Handle type
pub inline fn toObjectHandle(object: anytype) ObjectHandle {
	return @intCast(object);
}

pub inline fn fromObjectHandle(object: ObjectHandle, comptime T: type) T {
	return @intCast(object);
}

/// Returns ObjectPerms for other -Perms type
pub inline fn toObjectPerms(perms: anytype) ObjectPerms {
	return @bitCast(perms);
}

pub inline fn fromObjectPerms(perms: ObjectPerms, comptime T: type) T {
	return @bitCast(perms);
}

/// Changes the handle number for an object capability to the first non-reserved handle number.
pub fn relocate(comptime Handle: type, object: anytype) RelocateError!Handle {
	const handle = toObjectHandle(object);
	const result = syscall(.object_relocate, .{ handle });
	
	return switch(result.code) {
		.Ok => fromObjectHandle(result.value, Handle),
		.OutOfMemory => RelocateError.OutOfMemory,
		.BadHandle => RelocateError.BadHandle,
		.OutOfHandles => RelocateError.OutOfHandles,
		else => |c| c.genericError(),
	};
}

pub const RelocateError = error{
	OutOfMemory,
	BadHandle,
	OutOfHandles,
} || GenericError;

/// Changes the handle number for an object capability to the passed handle number
pub fn move(comptime Handle: type, object: Handle, dest: Handle) MoveError!void {
	const handle = toObjectHandle(object);
	const dest_handle = toObjectHandle(dest);
	const result = syscall(.object_move, .{ handle, dest_handle });

	return switch(result.code) {
		.Ok => {},
		.OutOfMemory => MoveError.OutOfMemory,
		.BadHandle => MoveError.BadHandle,
		.HandleInUse => MoveError.HandleInUse,
		else => |c| c.genericError(),
	};
}

pub const MoveError = error{
	OutOfMemory,
	BadHandle,
	HandleInUse,
} || GenericError;

/// Creates a new object capability at the first non-reserved handle number with permissions that
/// are a subset of the `object`'s permissions and `perms`.
pub fn reduce(comptime Handle: type, object: Handle, perms: anytype) ReduceError!Handle {
	const handle = toObjectHandle(object);
	const operms = toObjectPerms(perms);
	const result = syscall(.object_reduce, .{ handle, operms });

	return switch(result.code) {
		.Ok => fromObjectHandle(result.value, Handle),
		.OutOfMemory => ReduceError.OutOfMemory,
		.BadHandle => ReduceError.BadHandle,
		.OutOfHandles => ReduceError.OutOfHandles,
		.DescendentLimitExceeded => ReduceError.DescendentLimitExceeded,
		else => |c| c.genericError(),
	};
}

pub const ReduceError = error{
	OutOfMemory,
	BadHandle,
	OutOfHandles,
} || GenericError;

/// Creates a new object capability at the `dest` handle number with permissions that are a subset
/// of the 'object`'s permissions and `perms`.
pub fn reduce2(comptime Handle: type, object: Handle, perms: anytype, dest: Handle) Reduce2Error!void {
	const handle = toObjectHandle(object);
	const operms = toObjectPerms(perms);
	const dest_handle = toObjectHandle(dest);
	const result = syscall(.object_reduce2, .{ handle, operms, dest_handle });

	return switch(result.code) {
		.Ok => {},
		.OutOfMemory => ReduceError.OutOfMemory,
		.BadHandle => ReduceError.BadHandle,
		.HandleInUse => ReduceError.HandleInUse,
		.DescendentLimitExceeded => ReduceError.DescendentLimitExceeded,
		else => |c| c.genericError(),
	};
}

pub const Reduce2Error = error{
	OutOfMemory,
	BadHandle,
	HandleInUse,
} || GenericError;

/// Destroys all of `object`'s descendents.
pub fn reset(object: anytype) ResetError!void {
	const handle = toObjectHandle(object);
	const result = syscall(.object_reset, .{ handle });

	return switch(result.code) {
		.Ok => {},
		.BadHandle => ResetError.BadHandle,
		else => |c| c.genericError(),
	};
}

pub const ResetError = error{
	BadHandle,
};

/// Sets the parent of each of `object`'s children to `object`'s parent.
pub fn detatch(object: anytype) DetatchError!void {
	const handle = toObjectHandle(object);
	const result = syscall(.object_detatch, .{ handle });

	return switch(result.code) {
		.Ok => {},
		.BadHandle => DetatchError.BadHandle,
		else => |c| c.genericError(),
	};
}

pub const DetatchError = error{
	BadHandle,
} || GenericError;

/// Frees `object` after settings each of the `object's` children to `object`'s parent.
pub fn remove(object: anytype) RemoveError!void {
	const handle = toObjectHandle(object);
	const result = syscall(.object_remove, .{ handle });

	return switch(result.code) {
		.Ok => {},
		.BadHandle => RemoveError.BadHandle,
		else => |c| c.genericError(),
	};
}

pub const RemoveError = error{
	BadHandle,
} || GenericError;

/// Frees `object` after destroying all of `object`'s descendents.
pub fn destroy(object: anytype) DestroyError!void {
	const handle = toObjectHandle(object);
	const result = syscall(.object_destroy, .{ handle });

	return switch(result.code) {
		.Ok => {},
		.BadHandle => DestroyError.BadHandle,
		else => |c| c.genericError(),
	};
}

pub const DestroyError = error{
	BadHandle,
} || GenericError;

/// Reserves handle numbers from (inclusive) at to (exclusive) at+count, numbers may wrap.
pub fn reserve(start: anytype, count: Word) ReserveError!void {
	const handle = toObjectHandle(start);
	const result = syscall(.object_reserve, .{ handle, count });

	return switch (result.code) {
		.Ok => {},
		.OutOfMemory => ReserveError.OutOfMemory,
		.HandleInUse => ReserveError.HandleInUse,
		else => |c| c.genericError(),
	};
}

pub const ReserveError = error{
	OutOfMemory,
	HandleInUse,
} || GenericError;

/// Returns info about `object`
pub fn stat(object: anytype) StatError!ObjectInfo {
	const handle = toObjectHandle(object);
	const result = syscall(.object_stat, .{ handle });

	return switch(result.code) {
		.Ok => @bitCast(@as(u32, @truncate(result.value))),
		.BadHandle => GetPermsError.BadHandle,
		else => |c| c.genericError(),
	};
}

pub const StatError = error{
	BadHandle,
} || GenericError;
