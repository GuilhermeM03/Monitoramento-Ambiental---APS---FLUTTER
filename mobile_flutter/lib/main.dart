import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const EnvMonitorApp());
}

///
/// 🌱 MONITORAMENTO AMBIENTAL — EDIÇÃO 2024
/// Estilo premium inspirado em apps como Apple Weather & Google Material 3.
///
class EnvMonitorApp extends StatelessWidget {
  const EnvMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF00A676));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monitoramento Ambiental',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: baseScheme.copyWith(
          surface: const Color(0xFFF8F9FA),
          primary: const Color(0xFF00A676),
          secondary: const Color(0xFF009B72),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 28),
          titleMedium: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 18),
          bodyMedium: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 15),
          labelLarge: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class Metrics {
  final String? city;
  final double? temperature;
  final int? humidity;
  final String? description;
  final List<Pollutant> pollutants;

  Metrics({
    this.city,
    this.temperature,
    this.humidity,
    this.description,
    required this.pollutants,
  });

  factory Metrics.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'] ?? {};
    final air = json['air_quality'] ?? {};
    final List<Pollutant> pols = [];
    if (air['pollutants'] != null) {
      for (final p in air['pollutants']) {
        pols.add(Pollutant(
          parameter: p['parameter'],
          value: (p['value'] as num?)?.toDouble(),
          unit: p['unit'],
        ));
      }
    }
    return Metrics(
      city: json['city'],
      temperature: (weather['temperature'] as num?)?.toDouble(),
      humidity: weather['humidity'],
      description: weather['description'],
      pollutants: pols,
    );
  }
}

class Pollutant {
  final String parameter;
  final double? value;
  final String? unit;

  Pollutant({required this.parameter, this.value, this.unit});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _cityCtrl = TextEditingController(text: 'São Paulo');
  bool _loading = false;
  Metrics? _metrics;
  String? _error;

  Future<void> _fetch() async {
    final city = _cityCtrl.text.trim();
    if (city.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      const baseUrl = String.fromEnvironment('API_BASE',
          defaultValue: 'http://localhost:8000');
      final uri = Uri.parse(
          '$baseUrl/api/metrics?city=${Uri.encodeComponent(city)}&country=BR');
      final resp = await http.get(uri).timeout(const Duration(seconds: 20));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _metrics = Metrics.fromJson(data);
        });
      } else {
        setState(() {
          _error = 'Erro ${resp.statusCode}: ${resp.body}';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          'Monitoramento Ambiental',
          style: theme.textTheme.titleMedium!
              .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchBar(context),
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                _buildErrorState(context)
              else if (_metrics == null)
                _buildEmptyState()
              else
                Expanded(child: _MetricsView(m: _metrics!)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _cityCtrl,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Digite a cidade...',
              ),
              style: theme.textTheme.bodyMedium,
              onSubmitted: (_) => _fetch(),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: _loading ? null : _fetch,
            icon: const Icon(Icons.search, size: 18, color: Colors.white),
            label: const Text('Buscar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          _error ?? 'Erro desconhecido',
          style: TextStyle(
              color: Colors.red.shade400, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_outlined, color: Colors.grey.shade400, size: 64),
            const SizedBox(height: 12),
            const Text(
              'Pesquise uma cidade para ver os dados ambientais.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsView extends StatelessWidget {
  final Metrics m;
  const _MetricsView({required this.m});

  Map<String, dynamic> _getAqiStyle(double? aqi) {
    if (aqi == null) return {'color': Colors.grey, 'label': 'Sem dados'};
    if (aqi <= 50) return {'color': Colors.green, 'label': 'BOM'};
    if (aqi <= 100) return {'color': Colors.yellow[700], 'label': 'MODERADO'};
    if (aqi <= 150) return {'color': Colors.orange, 'label': 'PREJUDICIAL'};
    if (aqi <= 200) return {'color': Colors.red, 'label': 'INSALUBRE'};
    if (aqi <= 300)
      return {'color': Colors.purple, 'label': 'MUITO PREJUDICIAL'};
    return {'color': Colors.pinkAccent, 'label': 'PERIGOSO'};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final aqiPollutant = m.pollutants.firstWhere(
      (p) => p.parameter.toUpperCase() == 'AQI',
      orElse: () => Pollutant(parameter: 'AQI', value: null, unit: 'US AQI'),
    );

    final aqiStyle = _getAqiStyle(aqiPollutant.value);
    final Color baseColor = aqiStyle['color'];

    // Determina o poluente dominante (maior valor medido)
    final pollutantsWithoutAQI =
        m.pollutants.where((p) => p.parameter.toUpperCase() != 'AQI').toList();

    Pollutant? dominantPollutant;
    if (pollutantsWithoutAQI.isNotEmpty) {
      dominantPollutant = pollutantsWithoutAQI.reduce((a, b) {
        final va = a.value ?? 0;
        final vb = b.value ?? 0;
        return vb > va ? b : a;
      });
    }

    return ListView(
      children: [
        // 🌤️ Cartão de clima (novo, com gradiente estilizado)
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                baseColor.withOpacity(0.9),
                baseColor.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                m.city ?? '---',
                style: theme.textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                m.description ?? '-',
                style:
                    theme.textTheme.bodyMedium!.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Text(
                '${m.temperature?.toStringAsFixed(1) ?? '--'}°C',
                style: theme.textTheme.headlineLarge!
                    .copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Umidade: ${m.humidity ?? '--'}%',
                style:
                    theme.textTheme.bodyMedium!.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ☁️ Cartão de poluentes (mantido igual)
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor.withOpacity(0.25),
                baseColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Card(
            elevation: 0,
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Poluentes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Linha principal do AQI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('US AQI',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text(
                            aqiPollutant.value != null
                                ? '${aqiPollutant.value!.toStringAsFixed(0)}'
                                : '--',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            aqiPollutant.unit ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            aqiStyle['label'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: baseColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Lista de poluentes
                  for (final p in pollutantsWithoutAQI)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud,
                              size: 22, color: Colors.black54),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  p.parameter.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (dominantPollutant != null &&
                                    p.parameter.toUpperCase() ==
                                        dominantPollutant.parameter
                                            .toUpperCase()) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: baseColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Dominante',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: baseColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (p.value != null && p.value! > 0)
                            Text(
                              '${p.value!.toStringAsFixed(2)} ${p.unit ?? ""}',
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
