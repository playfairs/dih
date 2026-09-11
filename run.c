#include <stdlib.h>
#include <unistd.h>

int main() {
    execl("/usr/bin/env", "env", "swift", "run", (char *)NULL);
    return 1;
}