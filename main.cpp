#include <iostream>
#include <cstdlib>

#include "fast_marching.h"

int main()
{
    constexpr auto dim_x = 30ll;
    constexpr auto dim_y = 30ll;
    constexpr auto dim_z = 30ll;

    FastMarching3D fm(dim_x, dim_y, dim_z);
    fm.initSphere({ 0, 0, 0 }, 0.3);
    fm.run();

    auto grid = fm.result();

    printf("Distance field from corner (0,0,0) with r=0.3:\n");
    for (int x = 0; x < 10; ++x)
    {
        double dist = grid[std::array{ (long long)x, 0ll, 0ll }];
        printf("x=%2d: %6.2f\n", x, dist);
    }

    fm.saveToVTK("distance_field.vtk");

    return EXIT_SUCCESS;
}