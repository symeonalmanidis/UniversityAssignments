#include <iostream>
#include <cstdlib>

#include "fast_marching.h"

int main()
{
    
    constexpr auto dim_x = 30ll;
    constexpr auto dim_y = 30ll;
    constexpr auto dim_z = 30ll;
	
    FastMarching3D fm(dim_x, dim_y, dim_z);

	fm.initSphere({0, 0, 0}, 0.3);
	fm.run();
    fm.result();

    return EXIT_SUCCESS;
}