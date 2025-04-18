#include <stdio.h>

// 加法函数
double add(double a, double b) {
    return a + b;
}

// 减法函数
double subtract(double a, double b) {
    return a - b;
}

// 乘法函数
double multiply(double a, double b) {
    return a * b;
}

// 除法函数
double divide(double a, double b) {
    if (b == 0) {
        printf("错误：除数不能为零\n");
        return 0; // 返回0或其它错误处理方式
    }
    return a / b;
}

#if 0
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
#endif
