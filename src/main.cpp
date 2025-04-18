#include "math.h"
#include <stdio.h>

int main() {
    double num1, num2;

    printf("请输入两个数字: ");
    scanf("%lf %lf", &num1, &num2);

    printf("加法结果: %.2lf\n", add(num1, num2));
    printf("减法结果: %.2lf\n", subtract(num1, num2));
    printf("乘法结果: %.2lf\n", multiply(num1, num2));
    printf("除法结果: %.2lf\n", divide(num1, num2));

    return 0;
}