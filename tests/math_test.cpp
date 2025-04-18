#include "gtest/gtest.h"
#include "../src/math.h"

TEST(MathTest, Addition) {
    EXPECT_EQ(5.0, add(2.0, 3.0));
    EXPECT_NEAR(5.5, add(2.2, 3.3), 0.001);
}

TEST(MathTest, Subtraction) {
    EXPECT_EQ(1.0, subtract(4.0, 3.0));
}

TEST(MathTest, Multiplication) {
    EXPECT_EQ(6.0, multiply(2.0, 3.0));
}

TEST(MathTest, Division) {
    EXPECT_EQ(2.0, divide(6.0, 3.0));
    EXPECT_EQ(0.0, divide(6.0, 0.0)); // 测试除以零的情况
}