const builtin = @import("builtin");
const pic = builtin.position_independent_code or builtin.position_independent_executable;
const atmm = @import("atmm.zig");
const Word = atmm.Word;
const SyscallReturnCode = atmm.SyscallReturnCode;
const SyscallResult = atmm.SyscallResult;

//Entry
//	RAX = Syscall Number
//	RDI = Argument 1 (if Syscall Args >= 1)
//	RSI = Argument 2 (if Syscall Args >= 2)
//	RDX = Argument 3 (if Syscall Args >= 3)
//
//	If INT 0x6A, INT 0x6B, or SYSENTER is used then
//		RCX = Argument 4 (if Syscall Args == 4)
//	Else If SYSCALL is used then
//		RBX = Arugment 4 (if Syscall Args == 4) 
//
//	If SYSENTER or INT 0x6B is used then
//		RBX = Return RIP
//		RBP = Return RSP
//
//	If SYSCALL is used then
//		RCX = Return RIP (set by SYSCALL instruction)
//
//Return
//	RAX = Return Value
//	RDX = Return Code
//	All other registers preserved, unless a paramater is `Return %`

pub inline fn syscallIntDa(number: Word, arguments: anytype) SyscallResult {
	var value: Word = undefined;
	var code: SyscallReturnCode = undefined;

	switch (arguments.len) {
		0 => asm volatile("int $0xDA"
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		: "memory"),
		1 => asm volatile("int $0xDA"
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		: "memory"),
		2 => asm volatile("int $0xDA"
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		  [arg1] "{rsi}" (arguments[1]),
		: "memory"),
		3 => asm volatile("int $0xDA"
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		  [arg1] "{rsi}" (arguments[1]),
		  [arg2] "{rdx}" (arguments[2]),
		: "memory"),
		4 => asm volatile("int $0xDA"
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		  [arg1] "{rsi}" (arguments[1]),
		  [arg2] "{rdx}" (arguments[2]),
		  [arg3] "{rcx}" (arguments[3]),
		: "memory"),
		else => @compileError("Maximum of 4 syscall arguments exceeded"),
	}

	return .{ .value = value, .code = code };
}

pub inline fn syscallIntDb(number: Word, arguments: anytype) SyscallResult {	
	var value: Word = undefined;
	var code: SyscallReturnCode = undefined;

	const assembly = (if (pic)
		\\leaq 1f(%rip), %rbx
	else
		\\movq $1f, %rbx
	) ++ "\n" ++
		\\movq %rsp, %rbp
		\\int $0xDB
		\\1:
	;

	switch (arguments.len) {
		0 => asm volatile(assembly
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		: "rbx", "rbp", "memory"),
		1 => asm volatile(assembly
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		: "rbx", "rbp", "memory"),
		2 => asm volatile(assembly
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		  [arg1] "{rsi}" (arguments[1]),
		: "rbx", "rbp", "memory"),
		3 => asm volatile(assembly
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		  [arg1] "{rsi}" (arguments[1]),
		  [arg2] "{rdx}" (arguments[2]),
		: "rbx", "rbp", "memory"),
		4 => asm volatile(assembly
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		  [arg1] "{rsi}" (arguments[1]),
		  [arg2] "{rdx}" (arguments[2]),
		  [arg3] "{rcx}" (arguments[3]),
		: "rbx", "rbp", "memory"),
		else => @compileError("Maximum of 4 syscall arguments exceeded"),
	}

	return .{ .value = value, .code = code };
}

pub inline fn syscallSysenter(number: Word, arguments: anytype) SyscallResult {	
	var value: Word = undefined;
	var code: SyscallReturnCode = undefined;
	
	const assembly = (if (pic)
		\\leaq 1f(%rip), %rbx
	else
		\\movq $1f, %rbx
	) ++ "\n" ++ 
		\\movq %rsp, %rbp
		\\sysenter
		\\1:
	; //@compileLog(assembly, pic, builtin.position_independent_code, builtin.position_independent_executable);

	switch (arguments.len) {
		0 => asm volatile(assembly
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		: "rbx", "rbp", "memory"),
		1 => asm volatile(assembly
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		: "rbx", "rbp", "memory"),
		2 => asm volatile(assembly
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		  [arg1] "{rsi}" (arguments[1]),
		: "rbx", "rbp", "memory"),
		3 => asm volatile(assembly
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		  [arg1] "{rsi}" (arguments[1]),
		  [arg2] "{rdx}" (arguments[2]),
		: "rbx", "rbp", "memory"),
		4 => asm volatile(assembly
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		  [arg1] "{rsi}" (arguments[1]),
		  [arg2] "{rdx}" (arguments[2]),
		  [arg3] "{rcx}" (arguments[3]),
		: "rbx", "rbp", "memory"),
		else => @compileError("Maximum of 4 syscall arguments exceeded"),
	}

	return .{ .value = value, .code = code };
}

pub inline fn syscallSyscall(number: Word, arguments: anytype) SyscallResult {
	var value: Word = undefined;
	var code: SyscallReturnCode = undefined;

	switch (arguments.len) {
		0 => asm volatile("syscall"
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		: "rcx", "memory"),
		1 => asm volatile("syscall"
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		: "rcx", "memory"),
		2 => asm volatile("syscall"
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		  [arg1] "{rsi}" (arguments[1]),
		: "rcx", "memory"),
		3 => asm volatile("syscall"
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		  [arg1] "{rsi}" (arguments[1]),
		  [arg2] "{rdx}" (arguments[2]),
		: "rcx", "memory"),
		4 => asm volatile("syscall"
		: [value] "={rax}" (value),
		  [code] "={rdx}" (code),
		: [number] "{rax}" (number),
		  [arg0] "{rdi}" (arguments[0]),
		  [arg1] "{rsi}" (arguments[1]),
		  [arg2] "{rdx}" (arguments[2]),
		  [arg3] "{rbx}" (arguments[3]),
		: "rcx", "memory"),
		else => @compileError("Maximum of 4 syscall arguments exceeded"),
	}

	return .{ .value = value, .code = code };
}

pub const syscall = syscallSyscall;
