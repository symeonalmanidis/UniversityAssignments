#include <iostream>
#include <cstdlib>


#include "array3d.h"
#include "fast_marching.h"

int main()
{
    constexpr auto dim_x = 10;
    constexpr auto dim_y = 10;
    constexpr auto dim_z = 10;
    array3d<double> out_array(dim_x, dim_y, dim_z);
    out_array[3, 3, 3] = 5;
    std::cout << "Num: " << out_array[3, 3, 3];
    fast_marching(out_array);

    return EXIT_SUCCESS;
}