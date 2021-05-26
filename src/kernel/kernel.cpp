#include <krt.h>

EXTERN size_t strlen(const char*);

void entry()
{
	char* msg = "feed me NOW!";
	int msgLen = strlen(msg);
	char* vidmem = (char*)0xB8000;

	for(int i = 0; i < msgLen; ++i)
	{
		vidmem[2 * i] = msg[i];
		vidmem[(2 * i) + 1] = 0x1b;
	}

	while(true);
}
