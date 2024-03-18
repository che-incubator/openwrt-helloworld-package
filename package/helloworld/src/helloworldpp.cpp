#include <iostream>

using namespace std;

// C++ program to Demonstrate do-while loop
int main(void) {
    int i = 1; // initialization expression

    do {
        // loop body
         cout << i << ":Hello World!!!" << endl;

        // update expression
        i++;

    } while (i <= 10); // test expression

    return 0;
}
