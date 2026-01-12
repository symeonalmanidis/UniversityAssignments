#ifndef FAST_MARCHING_FAST_MARCHING_H
#define FAST_MARCHING_FAST_MARCHING_H

#include <ranges>
#include <mdspan>
#include <queue>
#include <fstream>
#include <string>

class FastMarching3D
{
private:
    struct Point
    {
        long long x, y, z;
    };

    template <typename T>
    using Span3D = std::mdspan<T, std::dextents<long long, 3>>;

    enum class State : uint8_t
    {
        FAR = 0,
        NARROW = 1,
        FROZEN = 2
    };

    long long dx{}, dy{}, dz{};
    std::vector<double> distanceGridBuffer;
    Span3D<double> distanceGrid;
    std::vector<State> stateGridBuffer;
    Span3D<State> stateGrid;

    auto up_to(long long n)
    {
        return std::views::iota(0ll, n);
    }

    double solveEikonal(long long x, long long y, long long z)
    {
        double T_min[3];

        auto getVal = [&](long long tx, long long ty, long long tz) 
        {
            if (tx >= 0 && tx < dx && ty >= 0 && ty < dy && tz >= 0 && tz < dz &&
                stateGrid[std::to_array({ tx, ty, tz })] == State::FROZEN) 
            {
                return distanceGrid[std::to_array({ tx, ty, tz })];
            }
            return std::numeric_limits<double>::max();
        };

        T_min[0] = std::min(getVal(x - 1, y, z), getVal(x + 1, y, z));
        T_min[1] = std::min(getVal(x, y - 1, z), getVal(x, y + 1, z));
        T_min[2] = std::min(getVal(x, y, z - 1), getVal(x, y, z + 1));

        std::ranges::sort(T_min);

        double T = T_min[0] + 1.0;
        if (T <= T_min[1]) return T;

        double distSq = (T_min[0] - T_min[1]) * (T_min[0] - T_min[1]);
        if (distSq < 2.0)
        {
            double T2 = (T_min[0] + T_min[1] + std::sqrt(2.0 - distSq)) / 2.0;
            if (T2 <= T_min[2]) return T2;
        }

        double sum = T_min[0] + T_min[1] + T_min[2];
        double sum_sq = T_min[0] * T_min[0] + T_min[1] * T_min[1] + T_min[2] * T_min[2];

        double disc = sum * sum - 3.0 * (sum_sq - 1.0);

        return (disc < 0) ? T_min[0] + 1.0 : (sum + std::sqrt(disc)) / 3.0;
    }

    bool attemptUpdateNeighbor(long long nx, long long ny, long long nz)
    {
        if (nx < 0 || nx >= dx || ny < 0 || ny >= dy || nz < 0 || nz >= dz)
            return false;

        auto idx = std::to_array({ nx, ny, nz });

        if (stateGrid[idx] == State::FROZEN)
            return false;

        double newDist = solveEikonal(nx, ny, nz);
        double currentDist = distanceGrid[idx];

        if (stateGrid[idx] == State::FAR || newDist < currentDist)
        {
            stateGrid[idx] = State::NARROW;
            distanceGrid[idx] = newDist;
            return true;
        }
        return false;
    }

public:
    explicit FastMarching3D(long long dim_x, long long dim_y, long long dim_z)
        : dx(dim_x), dy(dim_y), dz(dim_z),
        distanceGridBuffer(dim_x* dim_y* dim_z, std::numeric_limits<double>::max()),
        distanceGrid(distanceGridBuffer.data(), dim_x, dim_y, dim_z),
        stateGridBuffer(dim_x* dim_y* dim_z, State::FAR),
        stateGrid(stateGridBuffer.data(), dim_x, dim_y, dim_z)
    {

    }

    void addBoundaryVoxel(const Point& p, double knownDist)
    {
        distanceGrid[std::to_array({ p.x, p.y, p.z })] = knownDist;
        stateGrid[std::to_array({ p.x, p.y, p.z })] = State::FROZEN;

        static constexpr auto directions = std::to_array<Point>({
            {1,0,0}, {-1,0,0}, {0,1,0}, {0,-1,0}, {0,0,1}, {0,0,-1}
        });

        for (const auto& d : directions)
            attemptUpdateNeighbor(p.x + d.x, p.y + d.y, p.z + d.z);
    }

    inline void initSphere(const Point& center, double radius)
    {
        for (auto&& [x, y, z] : std::views::cartesian_product(up_to(dx), up_to(dy), up_to(dz)))
        {
            const auto dist_x = static_cast<double>(x - center.x);
            const auto dist_y = static_cast<double>(y - center.y);
            const auto dist_z = static_cast<double>(z - center.z);
            const double len = std::sqrt(dist_x * dist_x + dist_y * dist_y + dist_z * dist_z);
            const double distToSurface = len - radius;

            if (std::abs(distToSurface) < 1.0)
            {
                addBoundaryVoxel(Point{ x, y, z }, std::abs(distToSurface));
            }
        }
    }

    inline void run()
    {
        auto comparePoints = [this](const Point& a, const Point& b) {
            return distanceGrid[std::to_array({ a.x, a.y, a.z })] > distanceGrid[std::to_array({ b.x, b.y, b.z })];
        };

        std::priority_queue<Point, std::vector<Point>, decltype(comparePoints)> pq(comparePoints);

        for (auto&& [x, y, z] : std::views::cartesian_product(up_to(dx), up_to(dy), up_to(dz)))
        {
            if (stateGrid[std::to_array({ x, y, z })] == State::NARROW)
            {
                pq.push(Point{ x, y, z });
            }
        }

        static constexpr auto directions = std::to_array<Point>({
            {1,0,0}, {-1,0,0}, {0,1,0}, {0,-1,0}, {0,0,1}, {0,0,-1}
        });

        while (not pq.empty())
        {
            const Point current = pq.top();
            pq.pop();

            if (stateGrid[std::to_array({ current.x, current.y, current.z })] == State::FROZEN)
                continue;

            stateGrid[std::to_array({ current.x, current.y, current.z })] = State::FROZEN;

            for (const auto& d : directions)
            {
                long long nx = current.x + d.x;
                long long ny = current.y + d.y;
                long long nz = current.z + d.z;

                if (attemptUpdateNeighbor(nx, ny, nz))
                {
                    pq.push(Point{ nx, ny, nz });
                }
            }
        }
    }

    Span3D<double> result()
    {
        return distanceGrid;
    }

    void saveToVTK(const std::string& filename)
    {
        std::ofstream file(filename);
        if (!file.is_open()) return;

        // VTK Header
        file << "# vtk DataFile Version 3.0\n";
        file << "Fast Marching Distance Field\n";
        file << "ASCII\n";
        file << "DATASET STRUCTURED_POINTS\n";
        file << "DIMENSIONS " << dx << " " << dy << " " << dz << "\n";
        file << "ORIGIN 0 0 0\n";
        file << "SPACING 1 1 1\n";

        // Point Data
        file << "POINT_DATA " << (dx * dy * dz) << "\n";
        file << "SCALARS distance double 1\n";
        file << "LOOKUP_TABLE default\n";

        for (long long z = 0; z < dz; ++z)
            for (long long y = 0; y < dy; ++y)
                for (long long x = 0; x < dx; ++x)
                    file << distanceGrid[std::array{ x, y, z }] << "\n";

        file.close();
    }
};

#endif //FAST_MARCHING_FAST_MARCHING_H