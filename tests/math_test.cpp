#include "gtest/gtest.h"
#include "../src/math.h"

TEST(MathTest, Addition) {
    EXPECT_DOUBLE_EQ(5.0, add(2.0, 3.0));
}

TEST(MathTest, Division) {
    EXPECT_DOUBLE_EQ(2.0, divide(6.0, 3.0));
    EXPECT_DOUBLE_EQ(0.0, divide(6.0, 0.0));
}