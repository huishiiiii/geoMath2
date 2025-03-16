import 'package:geomath/helpers/text_constant.dart';

enum RoleEnum {
  student,
  teacher,
}

extension RoleEnumParseToString on RoleEnum {
  String enumToString() {
    switch (this) {
      case RoleEnum.student:
        return TextConstant.student;
      case RoleEnum.teacher:
        return TextConstant.teacher;
    }
  }
}
