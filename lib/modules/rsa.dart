String alfabeto = "abcdefghijklmnopqrstuvwxyz ";
var lista = alfabeto.split('');
final letras = {for (int i = 2; i < 29; i += 1) alfabeto[i - 2]: i};
final numeros = {for (int i = 2; i < 29; i += 1) i: alfabeto[i - 2]};

int modinv(int a, int b, int s0, int s1) {
  if (a % b == 0) return s1;
  int q = a ~/ b;
  return modinv(b, a % b, s1, s0 - s1 * q);
}

List<int> generatePublicKey(int p, int q, int e) {
  int n = p * q;
  return [n, e];
}

String listToString(List<int> arr) {
  var lista = [for (int i = 0; i < arr.length; i++) arr[i].toString()];
  return lista.join(" ");
}

List<int> encrypting(String mensage, int n, int e) {
  mensage = mensage.toLowerCase();
  List<int> code = [
    for (int i = 0; i < mensage.length; i++) letras[mensage[i]]!
  ];
  List<int> cripted = [];
  for (int i = 0; i < code.length; i++) {
    int value =
        BigInt.from(code[i]).modPow(BigInt.from(e), BigInt.from(n)).toInt();
    cripted.add(value);
  }
  return cripted;
}

// fazer funcao modpow

String decrypting(List<int> cripted, int p, int q, int e) {
  int tot = (p - 1) * (q - 1);
  int d = modinv(e, tot, 1, 0) % tot;
  int n = p * q;
  List<int> decrypted = [];
  for (int i = 0; i < cripted.length; i++) {
    int value =
        BigInt.from(cripted[i]).modPow(BigInt.from(d), BigInt.from(n)).toInt();
    decrypted.add(value);
  }
  var mensage = [
    for (int i = 0; i < decrypted.length; i++) numeros[decrypted[i]]
  ];
  return mensage.join();
}

void main() {
  //print(letras);
  //print(numeros);
  //print(generatePublicKey(13, 11, 7));
  //print(encrypting("ola mundo", 143, 7));
  //print(decrypting([3, 117, 128, 63, 53, 22, 115, 47, 3], 13, 11, 7));
}
