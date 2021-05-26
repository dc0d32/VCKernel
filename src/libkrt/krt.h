#ifndef _KRT_H_
#define _KRT_H_

#define NULL ((void*)0)

#define EXTERN		extern "C"
#define CALLCONV	__cdecl
#define EXPORT		EXTERN __declspec(dllexport)    // exported from DLL
#define IMPORT		EXTERN __declspec(dllimport)    // imported from DLL
#define NAKED		__declspec(naked)		// no prolog or epilog code added
#define NORETURN	__declspec(noreturn)


// intrinsics
EXTERN int _outp(unsigned short, int);
EXTERN unsigned short _outpw(unsigned short, unsigned short);
EXTERN int _inp(unsigned short);
EXTERN unsigned short _inpw(unsigned short);
EXTERN void *_ReturnAddress();

#define outb(prt, val)		_outp(prt, val)
#define inb(prt)		((unsigned char)_inp(prt))
#define outw(prt, val)		_outpw(prt, val)
#define inw(prt)		((unsigned short)_inpw(prt))
#define getRetAddr		_ReturnAddress

// kernel entry point
void entry();

#pragma comment(linker, "/merge:.CRT=.data")

#endif /* !_KRT_H_ */