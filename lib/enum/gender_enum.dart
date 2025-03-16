import 'package:geomath/helpers/text_constant.dart';

enum GenderEnum { female, male }

extension GenderEnumParseToString on GenderEnum {
  String enumToString() {
    switch (this) {
      case GenderEnum.female:
        return TextConstant.female;
      case GenderEnum.male:
        return TextConstant.male;
    }
  }
}
