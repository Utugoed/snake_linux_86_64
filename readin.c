#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>


int main(int argc, char* argv){
	printf("IGNBRK = %x\n", IGNBRK);
	printf("BRKINT = %x\n", BRKINT);
	printf("PARMRK = %x\n", PARMRK);
	printf("ISTRIP = %x\n", ISTRIP);
	printf("INLCR = %x\n", INLCR);
	printf("IGNCR = %x\n", IGNCR);
	printf("ICRNL = %x\n", ICRNL);

	printf("OPOST = %x\n", OPOST);

	printf("ECHO = %x\n", ECHO);
	printf("ECHONL = %x\n", ECHONL);
	printf("ICANON = %x\n", ICANON);
	printf("ISIG = %x\n", ISIG);
	printf("IEXTEN = %x\n", IEXTEN);

	printf("CSIZE = %x\n", CSIZE);
	printf("PARENB = %x\n", PARENB);

	printf("CS8 = %x\n", CS8);
	return 0;
}
