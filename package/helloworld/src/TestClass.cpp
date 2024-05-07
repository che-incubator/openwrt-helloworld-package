#include <iostream>

#include "TestClass.h"


TestClass::TestClass()
{
	std::cout << "TestClass::TestClass()" << std::endl;
}

void TestClass::printMessage()
{
	std::cout << "TestClass::printMessage()" << std::endl;

	std::cout << "This is test message to print" << std::endl;
}
// Path: package/helloworld/src/TestClass.h