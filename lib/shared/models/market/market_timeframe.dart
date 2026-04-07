enum MarketTimeframe {
  tick,
  minute1,
  minute3,
  minute5,
  minute10,
  minute15,
  minute30,
  minute45,
  minute60,
  day,
}

extension MarketTimeframeX on MarketTimeframe {
  bool get isMinuteCandle => this != MarketTimeframe.tick && this != MarketTimeframe.day;

  bool get isTick => this == MarketTimeframe.tick;

  bool get isDay => this == MarketTimeframe.day;

  String get protocolValue {
    switch (this) {
      case MarketTimeframe.tick:
        return 'tick';
      case MarketTimeframe.minute1:
        return '1m';
      case MarketTimeframe.minute3:
        return '3m';
      case MarketTimeframe.minute5:
        return '5m';
      case MarketTimeframe.minute10:
        return '10m';
      case MarketTimeframe.minute15:
        return '15m';
      case MarketTimeframe.minute30:
        return '30m';
      case MarketTimeframe.minute45:
        return '45m';
      case MarketTimeframe.minute60:
        return '60m';
      case MarketTimeframe.day:
        return '1d';
    }
  }

  String get kiwoomMinuteScope {
    switch (this) {
      case MarketTimeframe.minute1:
        return '1';
      case MarketTimeframe.minute3:
        return '3';
      case MarketTimeframe.minute5:
        return '5';
      case MarketTimeframe.minute10:
        return '10';
      case MarketTimeframe.minute15:
        return '15';
      case MarketTimeframe.minute30:
        return '30';
      case MarketTimeframe.minute45:
        return '45';
      case MarketTimeframe.minute60:
        return '60';
      case MarketTimeframe.tick:
      case MarketTimeframe.day:
        throw StateError('Tick/day timeframe does not have a minute scope.');
    }
  }

  static MarketTimeframe parse(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'tick':
      case 'ticks':
        return MarketTimeframe.tick;
      case '1m':
      case '1min':
      case '1minute':
        return MarketTimeframe.minute1;
      case '3m':
      case '3min':
        return MarketTimeframe.minute3;
      case '5m':
      case '5min':
        return MarketTimeframe.minute5;
      case '10m':
      case '10min':
        return MarketTimeframe.minute10;
      case '15m':
      case '15min':
        return MarketTimeframe.minute15;
      case '30m':
      case '30min':
        return MarketTimeframe.minute30;
      case '45m':
      case '45min':
        return MarketTimeframe.minute45;
      case '60m':
      case '60min':
      case '1h':
        return MarketTimeframe.minute60;
      case '1d':
      case 'day':
      case 'daily':
        return MarketTimeframe.day;
      default:
        throw ArgumentError('Unsupported timeframe: $raw');
    }
  }
}
