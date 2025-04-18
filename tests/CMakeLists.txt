cmake_minimum_required(VERSION 3.10)

# 关键修改1：查找线程库
find_package(Threads REQUIRED)

find_package(GTest REQUIRED)

add_executable(math_test
    math_test.cpp
    ../src/math.cpp
)

# 关键修改2：链接线程库
target_link_libraries(math_test 
    GTest::GTest 
    GTest::Main
    Threads::Threads  # 添加线程库
    pthread           # 部分系统需要显式链接
)

add_test(NAME math_test COMMAND math_test)