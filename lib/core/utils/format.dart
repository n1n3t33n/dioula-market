import 'package:intl/intl.dart';

final _fcfa = NumberFormat.decimalPattern('fr');

/// Formate un montant en FCFA avec séparateur de milliers.
/// Ex. : `formatFcfa(18000)` → « 18 000 FCFA ».
String formatFcfa(num value) => '${_fcfa.format(value)} FCFA';

/// Formate une quantité (sans décimales inutiles). Ex. : 20.0 → « 20 ».
String formatQty(num value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toString();
}
