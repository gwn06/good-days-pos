// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'form_product_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$FormProductData {
  String get productName => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  double get costPrice => throw _privateConstructorUsedError;
  double get sellingPrice => throw _privateConstructorUsedError;
  int get availableStock => throw _privateConstructorUsedError;
  int get quantitySold => throw _privateConstructorUsedError;
  DateTime get expiryDate => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FormProductDataCopyWith<FormProductData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FormProductDataCopyWith<$Res> {
  factory $FormProductDataCopyWith(
          FormProductData value, $Res Function(FormProductData) then) =
      _$FormProductDataCopyWithImpl<$Res>;
  $Res call(
      {String productName,
      String category,
      double costPrice,
      double sellingPrice,
      int availableStock,
      int quantitySold,
      DateTime expiryDate,
      String description});
}

/// @nodoc
class _$FormProductDataCopyWithImpl<$Res>
    implements $FormProductDataCopyWith<$Res> {
  _$FormProductDataCopyWithImpl(this._value, this._then);

  final FormProductData _value;
  // ignore: unused_field
  final $Res Function(FormProductData) _then;

  @override
  $Res call({
    Object? productName = freezed,
    Object? category = freezed,
    Object? costPrice = freezed,
    Object? sellingPrice = freezed,
    Object? availableStock = freezed,
    Object? quantitySold = freezed,
    Object? expiryDate = freezed,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      productName: productName == freezed
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      category: category == freezed
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      costPrice: costPrice == freezed
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as double,
      sellingPrice: sellingPrice == freezed
          ? _value.sellingPrice
          : sellingPrice // ignore: cast_nullable_to_non_nullable
              as double,
      availableStock: availableStock == freezed
          ? _value.availableStock
          : availableStock // ignore: cast_nullable_to_non_nullable
              as int,
      quantitySold: quantitySold == freezed
          ? _value.quantitySold
          : quantitySold // ignore: cast_nullable_to_non_nullable
              as int,
      expiryDate: expiryDate == freezed
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: description == freezed
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$_FormProductDataCopyWith<$Res>
    implements $FormProductDataCopyWith<$Res> {
  factory _$$_FormProductDataCopyWith(
          _$_FormProductData value, $Res Function(_$_FormProductData) then) =
      __$$_FormProductDataCopyWithImpl<$Res>;
  @override
  $Res call(
      {String productName,
      String category,
      double costPrice,
      double sellingPrice,
      int availableStock,
      int quantitySold,
      DateTime expiryDate,
      String description});
}

/// @nodoc
class __$$_FormProductDataCopyWithImpl<$Res>
    extends _$FormProductDataCopyWithImpl<$Res>
    implements _$$_FormProductDataCopyWith<$Res> {
  __$$_FormProductDataCopyWithImpl(
      _$_FormProductData _value, $Res Function(_$_FormProductData) _then)
      : super(_value, (v) => _then(v as _$_FormProductData));

  @override
  _$_FormProductData get _value => super._value as _$_FormProductData;

  @override
  $Res call({
    Object? productName = freezed,
    Object? category = freezed,
    Object? costPrice = freezed,
    Object? sellingPrice = freezed,
    Object? availableStock = freezed,
    Object? quantitySold = freezed,
    Object? expiryDate = freezed,
    Object? description = freezed,
  }) {
    return _then(_$_FormProductData(
      productName: productName == freezed
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      category: category == freezed
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      costPrice: costPrice == freezed
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as double,
      sellingPrice: sellingPrice == freezed
          ? _value.sellingPrice
          : sellingPrice // ignore: cast_nullable_to_non_nullable
              as double,
      availableStock: availableStock == freezed
          ? _value.availableStock
          : availableStock // ignore: cast_nullable_to_non_nullable
              as int,
      quantitySold: quantitySold == freezed
          ? _value.quantitySold
          : quantitySold // ignore: cast_nullable_to_non_nullable
              as int,
      expiryDate: expiryDate == freezed
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: description == freezed
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_FormProductData implements _FormProductData {
  _$_FormProductData(
      {this.productName = '',
      this.category = '',
      this.costPrice = 0,
      this.sellingPrice = 0,
      this.availableStock = 0,
      this.quantitySold = 0,
      required this.expiryDate,
      this.description = ''});

  @override
  @JsonKey()
  final String productName;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey()
  final double costPrice;
  @override
  @JsonKey()
  final double sellingPrice;
  @override
  @JsonKey()
  final int availableStock;
  @override
  @JsonKey()
  final int quantitySold;
  @override
  final DateTime expiryDate;
  @override
  @JsonKey()
  final String description;

  @override
  String toString() {
    return 'FormProductData(productName: $productName, category: $category, costPrice: $costPrice, sellingPrice: $sellingPrice, availableStock: $availableStock, quantitySold: $quantitySold, expiryDate: $expiryDate, description: $description)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_FormProductData &&
            const DeepCollectionEquality()
                .equals(other.productName, productName) &&
            const DeepCollectionEquality().equals(other.category, category) &&
            const DeepCollectionEquality().equals(other.costPrice, costPrice) &&
            const DeepCollectionEquality()
                .equals(other.sellingPrice, sellingPrice) &&
            const DeepCollectionEquality()
                .equals(other.availableStock, availableStock) &&
            const DeepCollectionEquality()
                .equals(other.quantitySold, quantitySold) &&
            const DeepCollectionEquality()
                .equals(other.expiryDate, expiryDate) &&
            const DeepCollectionEquality()
                .equals(other.description, description));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(productName),
      const DeepCollectionEquality().hash(category),
      const DeepCollectionEquality().hash(costPrice),
      const DeepCollectionEquality().hash(sellingPrice),
      const DeepCollectionEquality().hash(availableStock),
      const DeepCollectionEquality().hash(quantitySold),
      const DeepCollectionEquality().hash(expiryDate),
      const DeepCollectionEquality().hash(description));

  @JsonKey(ignore: true)
  @override
  _$$_FormProductDataCopyWith<_$_FormProductData> get copyWith =>
      __$$_FormProductDataCopyWithImpl<_$_FormProductData>(this, _$identity);
}

abstract class _FormProductData implements FormProductData {
  factory _FormProductData(
      {final String productName,
      final String category,
      final double costPrice,
      final double sellingPrice,
      final int availableStock,
      final int quantitySold,
      required final DateTime expiryDate,
      final String description}) = _$_FormProductData;

  @override
  String get productName => throw _privateConstructorUsedError;
  @override
  String get category => throw _privateConstructorUsedError;
  @override
  double get costPrice => throw _privateConstructorUsedError;
  @override
  double get sellingPrice => throw _privateConstructorUsedError;
  @override
  int get availableStock => throw _privateConstructorUsedError;
  @override
  int get quantitySold => throw _privateConstructorUsedError;
  @override
  DateTime get expiryDate => throw _privateConstructorUsedError;
  @override
  String get description => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_FormProductDataCopyWith<_$_FormProductData> get copyWith =>
      throw _privateConstructorUsedError;
}
