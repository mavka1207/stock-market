  // 20 stocks
  const List<String> watchlist = [
    'UNT', 'TRNS', 'EGP', 'PHG', 'SVT',
    'SNE', 'JOB', 'MDT', 'MDC', 'NC',
    'MO', 'BPOP', 'ALCO', 'SPXC', 'TRN',
    'ADM', 'GGG', 'BAC', 'LNC', 'PPG',
  ];
  
  const List<Map<String, String>> watchlistDetails = [
  {'symbol': 'UNT',  'name': 'Unit Corporation'},
  {'symbol': 'TRNS', 'name': 'Transcat'},
  {'symbol': 'EGP',  'name': 'EastGroup Properties'},
  {'symbol': 'PHG',  'name': 'Philips'},
  {'symbol': 'SVT',  'name': 'Servotronics'},
  {'symbol': 'SNE',  'name': 'Sony'},
  {'symbol': 'JOB',  'name': 'GEE Group'},
  {'symbol': 'MDT',  'name': 'Medtronic'},
  {'symbol': 'MDC',  'name': 'MDC Holdings'},
  {'symbol': 'NC',   'name': 'NACCO Industries'},
  {'symbol': 'MO',   'name': 'Altria Group'},
  {'symbol': 'BPOP', 'name': 'Popular Inc'},
  {'symbol': 'ALCO', 'name': 'Alico Inc'},
  {'symbol': 'SPXC', 'name': 'SPX Technologies'},
  {'symbol': 'TRN',  'name': 'Trinity Industries'},
  {'symbol': 'ADM',  'name': 'Archer-Daniels-Midland'},
  {'symbol': 'GGG',  'name': 'Graco Inc'},
  {'symbol': 'BAC',  'name': 'Bank of America'},
  {'symbol': 'LNC',  'name': 'Lincoln National'},
  {'symbol': 'PPG',  'name': 'PPG Industries'},
];

String getStockName(String symbol) {
  return watchlistDetails.firstWhere(
    (s) => s['symbol'] == symbol,
    orElse: () => {'name': symbol},
  )['name']!;
}
