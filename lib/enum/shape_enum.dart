import 'package:geomath/helpers/text_constant.dart';

enum ShapeEnum {
  cone,
  pyramid,
  sphere,
  cube,
  cuboid,
  cylinder,
  square,
  rectangle,
  triangle,
  pentagon,
  hexagon,
  heptagon,
  octagon,
  nonagon,
  decagon
}

extension ShapeEnumParseToString on ShapeEnum {
  String enumToString() {
    switch (this) {
      case ShapeEnum.cone:
        return TextConstant.cone;
      case ShapeEnum.pyramid:
        return TextConstant.pyramid;
      case ShapeEnum.sphere:
        return TextConstant.sphere;
      case ShapeEnum.cube:
        return TextConstant.cube;
      case ShapeEnum.cuboid:
        return TextConstant.cuboid;
      case ShapeEnum.cylinder:
        return TextConstant.cylinder;
      case ShapeEnum.square:
        return TextConstant.square;
      case ShapeEnum.rectangle:
        return TextConstant.rectangle;
      case ShapeEnum.triangle:
        return TextConstant.triangle;
      case ShapeEnum.pentagon:
        return TextConstant.pentagon;
      case ShapeEnum.hexagon:
        return TextConstant.hexagon;
      case ShapeEnum.heptagon:
        return TextConstant.heptagon;
      case ShapeEnum.octagon:
        return TextConstant.octagon;
      case ShapeEnum.nonagon:
        return TextConstant.nanogon;
      case ShapeEnum.decagon:
        return TextConstant.decagon;
    }
  }
}
