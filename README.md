### Fast Marching Method (FMM) 3D

This repository contains an implementation of the **Fast Marching Method** algorithm in C++, developed as part of a university assignment.

The goal is to compute the distance (Signed Distance Function – SDF) of every point in a 3D space from a reference object (a sphere of radius (R = 0.3) centered at ([0, 0, 0])), by solving the Eikonal equation.

## 📋 Features

* **Language:** Modern C++ (C++23 Standard)
* **Technologies:** Use of modern constructs such as `std::mdspan` and `std::ranges`
* **Algorithm:** FMM implementation using a Priority Queue (Min-Heap)
* **Output:** Results exported to a `.vtk` file (Structured Points) for easy visualization

## 🛠️ Requirements

Due to the use of recent C++ features (such as `<mdspan>`), a **modern compiler** with **C++23** support is required:

* GCC 13+
* Clang 16+
* MSVC (Visual Studio 2022 latest)

## 🚀 Execution

### 1. Compilation

On Linux/Mac:

```bash
g++ -std=c++23 main.cpp -o fmm_solver -O3
```

### 2. Run

```bash
./fmm_solver
```

After execution, a file named `distance_field.vtk` will be created in the directory.

## 📊 Visualization

To view the results (isosurfaces, distance field), you can open the `distance_field.vtk` file with **[ParaView](https://www.paraview.org/)**.

1. Open the file in ParaView.
2. Click **Apply**.
3. Use filters such as **Contour** (for isosurfaces) or **Slice** (for cross-sections) to observe the propagation of the wavefront.
