//! # Process
//! This file provides interfaces to system calls for manipulating a processes.

const atmm = @import("atmm.zig");
const Word = atmm.Word;
const syscall = atmm.syscall;
const GenericError = atmm.GenericError;

pub const ProcessHandle = atmm.object.ObjectHandle;

pub const ProcessPerms = packed struct(atmm.object.ObjectPerms) {
	
}

pub fn insert() {

}

pub fn insert2() {

}

pub fn extract() {

}

pub fn extract2() {

}

pub fn remove() {

}

pub fn 
