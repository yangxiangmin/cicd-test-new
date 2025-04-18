cmake_minimum_required(VERSION 3.10)
project(MathOperations)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 主程序
add_executable(math_app 
    src/math.cpp
    src/main.cpp
)

# 测试配置
enable_testing()
add_subdirectory(tests)