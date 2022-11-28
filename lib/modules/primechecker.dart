// Check if a number is prime

int isPrime(BigInt n) {
  if (n <= BigInt.from(1)) return 0;
  for (BigInt i = BigInt.two; i < n; i += BigInt.one) {
    if (n.modPow(BigInt.one, i) == BigInt.zero) return 0;
    if (i * i > n) return 1;
  }
  return 1;
}

// mdc of a number
BigInt mdc(BigInt a, BigInt b) {
  if (b == BigInt.zero) return a;
  return mdc(b, a.modPow(BigInt.one, b));
}
