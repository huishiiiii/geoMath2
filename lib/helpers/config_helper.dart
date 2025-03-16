class ConfigHelper {
  static final emailReg = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static final phoneRegExp = RegExp(r"^(6?01)[0-46-9]*[0-9]{7,8}$");
}
