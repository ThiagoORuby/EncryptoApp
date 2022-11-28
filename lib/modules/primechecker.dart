// Check if a number is prime

int isPrime(int n) {
  if (n <= 1) return 0;
  for (int i = 2; i < n; i++) {
    if (n % 2 == 0) return 0;
    if (i * i > n || n == 2) return 1;
  }
  return 1;
}
