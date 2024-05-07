#include <iostream>
#include <memory>
#include <string>

#include "TestClass.h"

using namespace std;

// C++ program to Demonstrate do-while loop
int main(void)
{
	string s = "Hello, World! This is a C++ test";
    int8_t i = 1;

    do {
        // loop body
         cout << i << s << endl;

        // update expression
        i++;

    } while (i <= 10); // test expression

	unique_ptr<TestClass> testClassInstance = make_unique<TestClass>();
	testClassInstance->printMessage();

	return 0;
}
