#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#define SOCKETNAME "/tmp/stampersock"
#define BUFFSIZE 64

int main(int argc, char const *argv[]) {
	struct sockaddr_un name = { 0 };
	int err;
	int mastersock;
	int clientsock;
	char buffer[BUFFSIZE] = { 0 };

	unlink(SOCKETNAME);

	mastersock = socket(AF_UNIX, SOCK_STREAM, 0);
	if (mastersock < 0) {
		exit(EXIT_FAILURE);
	}

	name.sun_family = AF_UNIX;
	strncpy(name.sun_path, SOCKETNAME, sizeof(name.sun_path) - 1);

	err = bind(mastersock, (const struct sockaddr *) &name, sizeof(struct sockaddr_un));
	if (err < 0) {
		exit(EXIT_FAILURE);
	}

	err = listen(mastersock, 20);
	if (err < 0) {
		exit(EXIT_FAILURE);
	}

	// Blocking IO seems fine here. I can't imagine a reason why
	// to implement async IO here. But if it's neccessary, it is
	// quickly ported to poll(2).
	while (1) {
		printf("Waiting for connection.\n");
		clientsock = accept(mastersock, NULL, NULL);
		if (clientsock < 0) {
			exit(EXIT_FAILURE);
		}

		while (1) {
			err = read(clientsock, buffer, BUFFSIZE);
			if (err < 0) {
				exit(EXIT_FAILURE);
			} else if (err == 0) {
				printf("Connection lost.\n");
				break;
			}

			buffer[BUFFSIZE - 1] = 0;

			printf("%s", buffer);

			memset(buffer, 0, BUFFSIZE);
		}
	}

	close(mastersock);
	unlink(SOCKETNAME);
	return EXIT_SUCCESS;
}
