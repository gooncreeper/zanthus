const builtin = @import("builtin");
const pic = builtin.position_independent_code or builtin.position_independent_executable;
const atmm = @import("atmm.zig");
const Word = atmm.Word;
const SyscallReturnCode = atmm.SyscallReturnCode;
const SyscallResult = atmm.SyscallResult;

//Entry
//	EAX = Syscall Number
//	EDI = Argument 1 (if Syscall Args >= 1)
//	ESI = Argument 2 (if Syscall Args >= 2)
//	EDX = Argument 3 (if Syscall Args >= 3)
//
//	If INT 0x6A, INT 0x6B, or SYSENTER is used then
//		ECX = Argument 4 (if Syscall Args == 4)
//	Else If SYSCALL is used then
//		EBX = Arugment 4 (if Syscall Args == 4) 
//
//	If SYSENTER or INT 0x6B is used then
//		EBX = Return RIP
//		EBP = Return RSP
//
//	If SYSCALL is used then
//		ECX = Return EIP (set by SYSCALL instruction)
//
//Return
//	EAX = Return Value
//	EDX = Return Code
//	All other registers preserved, unless a paramater is `Return %`

pub inline fn syscallIntDa(number: Word, arguments: anytype) SyscallResult {
	var value: Word = undefined;
	var code: SyscallReturnCode = undefined;

	switch (arguments.len) {
		0 => asm volatile("int $0xDA"
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		: "memory"),
		1 => asm volatile("int $0xDA"
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		: "memory"),
		2 => asm volatile("int $0xDA"
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		  [arg1] "{esi}" (arguments[1]),
		: "memory"),
		3 => asm volatile("int $0xDA"
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		  [arg1] "{esi}" (arguments[1]),
		  [arg2] "{edx}" (arguments[2]),
		: "memory"),
		4 => asm volatile("int $0xDA"
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		  [arg1] "{esi}" (arguments[1]),
		  [arg2] "{edx}" (arguments[2]),
		  [arg3] "{ecx}" (arguments[3]),
		: "memory"),
		else => @compileError("Maximum of 4 syscall arguments exceeded"),
	}

	return .{ .value = value, .code = code };
}

pub inline fn syscallIntDb(number: Word, arguments: anytype) SyscallResult {	
	var value: Word = undefined;
	var code: SyscallReturnCode = undefined;

	const assembly = (if (pic)
		\\calll 1f
		\\1:
		\\pop %ebx
		\\addl $(2f-1b), %ebx
	else
		\\movl $2f, %ebx
	) ++ "\n" ++
		\\movl %esp, %ebp
		\\int $0xDB
		\\2:
	;

	switch (arguments.len) {
		0 => asm volatile(assembly
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		: "ebx", "ebp", "memory"),
		1 => asm volatile(assembly
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		: "ebx", "ebp", "memory"),
		2 => asm volatile(assembly
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		  [arg1] "{esi}" (arguments[1]),
		: "ebx", "ebp", "memory"),
		3 => asm volatile(assembly
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		  [arg1] "{esi}" (arguments[1]),
		  [arg2] "{edx}" (arguments[2]),
		: "ebx", "ebp", "memory"),
		4 => asm volatile(assembly
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		  [arg1] "{esi}" (arguments[1]),
		  [arg2] "{edx}" (arguments[2]),
		  [arg3] "{ecx}" (arguments[3]),
		: "ebx", "ebp", "memory"),
		else => @compileError("Maximum of 4 syscall arguments exceeded"),
	}

	return .{ .value = value, .code = code };
}

pub inline fn syscallSysenter(number: Word, arguments: anytype) SyscallResult {	
	var value: Word = undefined;
	var code: SyscallReturnCode = undefined;
	
	const assembly = (if (pic)
		\\calll 1f
		\\1:
		\\pop %ebx
		\\addl $(2f-1b), %ebx
	else
		\\movl $2f, %ebx
	) ++ "\n" ++
		\\movl %esp, %ebp
		\\sysenter
		\\2:
	;

	switch (arguments.len) {
		0 => asm volatile(assembly
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		: "ebx", "ebp", "memory"),
		1 => asm volatile(assembly
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		: "ebx", "ebp", "memory"),
		2 => asm volatile(assembly
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		  [arg1] "{esi}" (arguments[1]),
		: "ebx", "ebp", "memory"),
		3 => asm volatile(assembly
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		  [arg1] "{esi}" (arguments[1]),
		  [arg2] "{edx}" (arguments[2]),
		: "ebx", "ebp", "memory"),
		4 => asm volatile(assembly
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		  [arg1] "{esi}" (arguments[1]),
		  [arg2] "{edx}" (arguments[2]),
		  [arg3] "{ecx}" (arguments[3]),
		: "ebx", "ebp", "memory"),
		else => @compileError("Maximum of 4 syscall arguments exceeded"),
	}

	return .{ .value = value, .code = code };
}

pub inline fn syscallSyscall(number: Word, arguments: anytype) SyscallResult {
	var value: Word = undefined;
	var code: SyscallReturnCode = undefined;

	switch (arguments.len) {
		0 => asm volatile("syscall"
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		: "ecx", "memory"),
		1 => asm volatile("syscall"
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		: "ecx", "memory"),
		2 => asm volatile("syscall"
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		  [arg1] "{esi}" (arguments[1]),
		: "ecx", "memory"),
		3 => asm volatile("syscall"
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		  [arg1] "{esi}" (arguments[1]),
		  [arg2] "{edx}" (arguments[2]),
		: "ecx", "memory"),
		4 => asm volatile("syscall"
		: [value] "={eax}" (value),
		  [code] "={edx}" (code),
		: [number] "{eax}" (number),
		  [arg0] "{edi}" (arguments[0]),
		  [arg1] "{esi}" (arguments[1]),
		  [arg2] "{edx}" (arguments[2]),
		  [arg3] "{ebx}" (arguments[3]),
		: "ecx", "memory"),
		else => @compileError("Maximum of 4 syscall arguments exceeded"),
	}

	return .{ .value = value, .code = code };
}

pub const syscall = syscallSysenter;
