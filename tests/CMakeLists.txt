find_package(GTest REQUIRED)

add_executable(math_test
    math_test.cpp
    ../src/math.cpp
)

target_link_libraries(math_test 
    GTest::GTest 
    GTest::Main
)

add_test(NAME math_test COMMAND math_test)