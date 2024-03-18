.PHONY: helloworldpp
helloworldpp: helloworldpp.cpp
	$(CXX) $(CXXFLAGS) -Wall -O3 -o $@ $^ $(LD_LIBS)

.PHONY: clean
clean:
	rm -fv *.o helloworldpp
