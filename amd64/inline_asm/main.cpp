
int main() {

    asm("mov rax, 60\n");
    asm("mov rdi, 0\n");
    asm("syscall\n");

}
