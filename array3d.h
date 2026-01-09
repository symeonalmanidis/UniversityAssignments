#ifndef FAST_MARCHING_ARRAY3D_H
#define FAST_MARCHING_ARRAY3D_H
#include <vector>

template <typename T>
class array3d
{
private:
    std::vector<T> data;
    std::size_t dim_x, dim_y, dim_z;
public:
    array3d(std::size_t dim_x, std::size_t dim_y, std::size_t dim_z)
        : data(dim_x* dim_y* dim_z), dim_x(dim_x), dim_y(dim_y), dim_z(dim_z)
    {

    }

    template< class... OtherIndexTypes >
    T& operator[](OtherIndexTypes... indices)
    {
        static_assert(sizeof...(indices) == 3, "Must provide exactly 3 indices");

        const std::size_t strides[] = { 1, dim_x, dim_x * dim_y };

        std::size_t flat_index{0uz};
        int i{};

        ((flat_index += indices * strides[i++]), ...);

        return data[flat_index];
    }
};


#endif //FAST_MARCHING_ARRAY3D_H