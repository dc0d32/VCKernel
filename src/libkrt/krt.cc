#include <krt.h>

// mem
void* CALLCONV ::operator new (unsigned int) { return 0; }
void* CALLCONV operator new[] (unsigned int) { return 0; }
void CALLCONV ::operator delete (void *) {}
void CALLCONV operator delete[] (void *) { }

// c++
int CALLCONV ::_purecall() { while(1); }

// floating point support
EXTERN int _fltused = 1;


// ctor/dtor
typedef void (__cdecl *_PVFV)(void);

#pragma data_seg(".CRT$XCA")
_PVFV __xc_a[] = { (_PVFV)NULL };
#pragma data_seg(".CRT$XCZ")
_PVFV __xc_z[] = { (_PVFV)NULL };
#pragma data_seg()

void __run_global_ctors()
{
	_PVFV * pfbegin = __xc_a;
	_PVFV * pfend  = __xc_z;

    // Go through each initializer
    while ( pfbegin < pfend )
    {
      // Execute the global initializer
      if ( *pfbegin != NULL )
            (**pfbegin) ();
 
	// Go to next initializer inside the initializer table
        ++pfbegin;
    }
}

EXTERN void CALLCONV _krt_init(void)
{
	__run_global_ctors();
	entry();
	// cleanup?? meh!
}

