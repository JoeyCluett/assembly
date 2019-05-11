#include <stdio.h>
#include <stdlib.h>

// assuming 32-bit addressing
// the structure of NODE is known 
// and so can be accounted for in asm
typedef struct NODE {
    struct NODE* next;
    int data;
} node_t;

node_t* new_node(node_t* child, int data);
void print_list(node_t* n);
void list_iter_callback(int i);

// asm routines have names that gcc needs to know about ahead of time.
// just tells the linker to look for them later
extern int sumargvec(int, ...);
extern void listiter(node_t*);
extern void listitercall(node_t*, void(*c)(int));
extern int listsize(node_t*);

int main(void) {

    int i;
    for(i = 0; i < 10; i++) {
        printf("From sumargvec: %d\n", sumargvec(6, i, 1, 2, 3, 4, 5));
    }

    // build the list
    node_t* n_ptr = new_node(NULL, 0);
    for(i = 1; i < 10; i++) {
        node_t* m_ptr = new_node(n_ptr, i);
        n_ptr = m_ptr;
    }
    
    listiter(n_ptr);
    listitercall(n_ptr, list_iter_callback);

    printf("\nSize of list:      %d\n", listsize(n_ptr));
    // add more stuff to the list
    for(i = 0; i < 10; i++)
        n_ptr = new_node(n_ptr, i+10);
    printf("Size of new list:  %d\n", listsize(n_ptr));
    printf("Size of NULL list: %d\n", listsize(NULL));

    return 0;
}

void list_iter_callback(int i) {
    printf("callback: %d\n", i);
}

node_t* new_node(node_t* child, int data) {
    node_t* n_ptr = (node_t*)malloc(sizeof(node_t));
    n_ptr->next = child;
    n_ptr->data = data;
    return n_ptr;
}

void print_list(node_t* n) {
    while(n) {
        printf("%d\n", n->data);
        n = n->next;
    }
}
