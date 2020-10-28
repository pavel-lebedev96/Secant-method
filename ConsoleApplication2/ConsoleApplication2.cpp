#include "pch.h"
#include <iostream>
extern "C" int N = 0;
extern "C" float SOLVE(float a, float b, float e);
using namespace std;
int main()
{
	float a, b, eps,res;
	cout << "a , b = ";
	cin >> a >> b;
	cout << "eps = ";
	cin >> eps;
	res = SOLVE(a, b, eps);
	cout << "res = " << res << endl;
	cout << "n = " << N << endl;
	system("pause");
}
