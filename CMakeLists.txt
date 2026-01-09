cmake_minimum_required(VERSION 3.5)
project(fast_marching)

set(CMAKE_CXX_STANDARD 23)

add_executable(fast_marching main.cpp
        fast_marching.h
        array3d.h)
