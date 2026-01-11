#ifndef FAST_MARCHING_FAST_MARCHING_H
#define FAST_MARCHING_FAST_MARCHING_H

#include <ranges>
#include <mdspan>
#include <queue>





class FastMarching3D {
private:
    struct Point {
        long long x, y, z;
    };

	template <typename T>
    using Span3D = std::mdspan<T, std::dextents<long long, 3>>;

	
    enum class State : uint8_t {
        FAR = 0,
        NARROW = 1,
        FROZEN = 2
	};

    long long dx{2}, dy{}, dz{};
    std::vector<double> distanceGridBuffer;
    Span3D<double> distanceGrid;
    std::vector<State> stateGridBuffer;
    Span3D<State> stateGrid;

    auto up_to(long long n) {
        return std::views::iota(0ll, n);
    }
public:
	explicit FastMarching3D(long long dim_x, long long dim_y, long long dim_z)
		: dx(dim_x), dy(dim_y), dz(dim_z),
          distanceGridBuffer(dim_x * dim_y * dim_z),
          distanceGrid(distanceGridBuffer.data(), dim_x, dim_y, dim_z),
          stateGridBuffer(dim_x * dim_y * dim_z, State::FAR),
          stateGrid(stateGridBuffer.data(), dim_x, dim_y, dim_z)
	{
		
	}
	
    void addBoundaryVoxel(const Point& p, double knownDist) {
        // 1. Set the exact distance (e.g., calculated via geometry)
        distanceGrid[std::to_array({p.x, p.y, p.z})] = knownDist;
        // 2. Freeze it immediately
        stateGrid[std::to_array({ p.x, p.y, p.z })] = State::FROZEN;
        
        // 3. Add its neighbors to the Narrow Band
        updateNeighbors(p);
    }

    void updateNeighbors(const Point& p) {
        static constexpr auto directions = std::to_array<Point>({Point{1ll, 0ll, 0ll}, Point{-1ll,  0ll, 0ll},
                                                                 Point{0ll, 1ll, 0ll}, Point{ 0ll, -1ll, 0ll},
                                                                 Point{0ll, 0ll, 1ll}, Point{ 0ll,  0ll,-1ll} });
        for (const auto& direction : directions) {
            long long nx = p.x + direction.x;
            long long ny = p.y + direction.y;
            long long nz = p.z + direction.z;
            // Check bounds
            const bool is_valid = (nx >= 0 and nx < static_cast<long long>(dx) &&
                                   ny >= 0 and ny < static_cast<long long>(dy) &&
				                   nz >= 0 and nz < static_cast<long long>(dz));
            if (not is_valid)
                continue;
            // Only update if it's still FAR
            if (stateGrid[std::to_array({ p.x, p.y, p.z })] == State::FAR) {
                stateGrid[std::to_array({ p.x, p.y, p.z })] = State::NARROW;
                // Initial distance can be set to a large value
                distanceGrid[std::to_array({ p.x, p.y, p.z })] = std::numeric_limits<double>::max();
            }

		}
    }

	inline void initSphere(const Point& center, double radius ) {
        for (auto&& [x, y, z] : std::views::cartesian_product(up_to(dx), up_to(dy), up_to(dz))) {
            // Calculate distance from voxel center to sphere center
            const auto dx = static_cast<double>(x - center.x);
            const auto dy = static_cast<double>(y - center.y);
            const auto dz = static_cast<double>(z - center.z);
            const double len = std::sqrt(dx * dx + dy * dy + dz * dz);

            // Distance to the surface
            const double distToSurface = len - radius;

            // Check if the voxel is inside or very close to the surface boundary.
            // In a signed distance field, inside is negative. 
            // For FMM (unsigned), we typically seed the voxels just *outside* the shape 
            // or the voxels intersecting the boundary.

            // Simple approach: Seed voxels within 1 unit of the surface
            if (std::abs(distToSurface) < 1.0) {
                // We use absolute distance because FMM propagates positive distances
                addBoundaryVoxel(Point{x, y, z}, std::abs(distToSurface));
            }
        }
	}

	inline void run()
	{
        auto comparePoints = 
            [this](const Point& a, const Point& b) {
                return distanceGrid[std::to_array({a.x, a.y, a.z})] > distanceGrid[std::to_array({b.x, b.y, b.z})];
			};

        std::priority_queue<Point, std::vector<Point>, decltype(comparePoints)> pq;

        for (auto&& [x, y, z] : std::views::cartesian_product(up_to(dx), up_to(dy), up_to(dz))) {
			if (stateGrid[std::to_array({ x, y, z })] == State::NARROW) {
                pq.push(Point{ x, y, z });
            }
        }

        while (not pq.empty()) {
            const Point current = pq.top(); pq.pop();
            if (stateGrid[std::to_array({current.x, current.y, current.z})] == State::FROZEN) 
                continue;
            stateGrid[std::to_array({ current.x, current.y, current.z })] = State::FROZEN;
            updateNeighbors(current);
        }
	}

	Span3D<double> result() {
		return distanceGrid;
	}
};

#endif //FAST_MARCHING_FAST_MARCHING_H