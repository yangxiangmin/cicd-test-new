# 启用GTest的JUnit输出
set(GTEST_DISABLE_PTHREADS ON)
set(GTEST_CREATE_JUNIT_OUTPUT ON)
add_executable(math_test math_test.cpp ../src/math.cpp)
target_link_libraries(math_test gtest gtest_main pthread)
add_test(NAME math_test COMMAND math_test)