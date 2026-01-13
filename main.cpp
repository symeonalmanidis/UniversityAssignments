#include <print>
#include <cstdlib>

#include "fast_marching.h"

int main()
{
    // Increase grid size for better resolution
    constexpr auto dim_x = 50ll;
    constexpr auto dim_y = 50ll;
    constexpr auto dim_z = 50ll;

    // Center coordinates
    const long long cx = dim_x / 2;
    const long long cy = dim_y / 2;
    const long long cz = dim_z / 2;

    // 1. SPHERE
    // Center: Middle of grid
    // Radius: 15.0 (fits well inside 50x50x50)
    {
        FastMarching3D fm(dim_x, dim_y, dim_z);
        fm.initSphere({ cx, cy, cz }, 15.0);
        fm.run();
        fm.saveToVTK("sphere.vtk");
        std::println("Generated sphere.vtk");
    }

    // 2. BOX
    // Center: Middle
    // Size: 20x20x20 (min: center-10, max: center+10)
    {
        FastMarching3D fm(dim_x, dim_y, dim_z);

        fm.initBox({ cx - 10, cy - 10, cz - 10 }, { cx + 10, cy + 10, cz + 10 });
        fm.run();
        fm.saveToVTK("box.vtk");
        std::println("Generated box.vtk");
    }

    // 3. CONE
    // Center: Middle
    // Radius: 12.0
    // Height: 25.0
    {
        FastMarching3D fm(dim_x, dim_y, dim_z);

        fm.initCone({ cx, 5, cz }, 12.0, 35.0);
        fm.run();
        fm.saveToVTK("cone.vtk");
        std::println("Generated cone.vtk");
    }

    return EXIT_SUCCESS;
}