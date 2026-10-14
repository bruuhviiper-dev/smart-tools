import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';

/// Conversor de moedas com cotação online (open.er-api.com, grátis, sem chave).
/// As taxas ficam cacheadas — funciona offline depois da 1ª atualização.
class CurrencyTool extends StatefulWidget {
  const CurrencyTool({super.key});
  @override
  State<CurrencyTool> createState() => _CurrencyToolState();
}

class _CurrencyToolState extends State<CurrencyTool> {
  // Moedas validadas contra a API (open.er-api), cobrindo os 6 mercados do app.
  static const _codes = [
    'USD', 'EUR', 'GBP', 'BRL', 'INR', 'CNY', 'JPY',
    'AED', 'SAR', 'QAR', 'KWD', 'EGP', 'MAD',
    'ARS', 'MXN', 'COP', 'CLP', 'PEN',
    'HKD', 'TWD', 'CAD', 'AUD', 'TRY', 'ZAR', 'NGN',
    'AOA', 'MZN'
  ];
  Map<String, double> _rates = {}; // base USD
  String _from = 'USD', _to = 'BRL';
  double _amount = 1;
  String? _updated;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cur_rates');
    if (cached != null) {
      final m = jsonDecode(cached) as Map<String, dynamic>;
      _rates = (m['rates'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble()));
      _updated = m['updated'] as String?;
      setState(() => _loading = false);
    }
    try {
      final r = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
          .timeout(const Duration(seconds: 10));
      final j = jsonDecode(r.body) as Map<String, dynamic>;
      if (j['result'] == 'success') {
        final rates = (j['rates'] as Map)
            .map((k, v) => MapEntry(k as String, (v as num).toDouble()));
        final updated = (j['time_last_update_utc'] as String?)?.split(' 00:')[0];
        _rates = rates;
        _updated = updated;
        await prefs.setString(
            'cur_rates', jsonEncode({'rates': rates, 'updated': updated}));
      }
    } catch (_) {
      if (_rates.isEmpty) _error = true;
    }
    if (mounted) setState(() => _loading = false);
  }

  double? get _result {
    final f = _rates[_from], tr = _rates[_to];
    if (f == null || tr == null || f == 0) return null;
    return _amount / f * tr; // via base USD
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(t.currencyConverter)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error && _rates.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(t.currencyConverter)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(t.needInternet),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: Text(t.retry)),
            ],
          ),
        ),
      );
    }
    final res = _result;
    return Scaffold(
      appBar: AppBar(title: Text(t.currencyConverter)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => setState(
                () => _amount = double.tryParse(v.replaceAll(',', '.')) ?? 0),
            decoration: InputDecoration(
              labelText: t.amount,
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _dd(_from, (v) => setState(() => _from = v!))),
              IconButton(
                icon: const Icon(Icons.swap_horiz_rounded),
                onPressed: () => setState(() {
                  final tmp = _from;
                  _from = _to;
                  _to = tmp;
                }),
              ),
              Expanded(child: _dd(_to, (v) => setState(() => _to = v!))),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.gradient(kToolGradients[6]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Text('${_amount.toStringAsFixed(2)} $_from',
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                    res == null
                        ? '—'
                        : '${res.toStringAsFixed(2)} $_to',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          if (_updated != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Center(
                child: Text('${t.updated}: $_updated',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dd(String value, ValueChanged<String?> onCh) => DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
        ),
        items: [
          for (final c in _codes)
            if (_rates.containsKey(c))
              DropdownMenuItem(value: c, child: Text(c)),
        ],
        onChanged: onCh,
      );
}
