add_executable(math_test math_test.cpp ../src/math.cpp)
target_link_libraries(math_test gtest gtest_main pthread)
add_test(NAME math_test COMMAND math_test)