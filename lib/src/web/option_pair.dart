/// Maps a [ConverterOption] ID to the `from`/`to` locale pair expected by the
/// opencc-js `Converter` constructor.
enum OptionPair {
  /// Simplified Chinese to Traditional Chinese.
  s2t(from: 'cn', to: 't'),

  /// Traditional Chinese to Simplified Chinese.
  t2s(from: 't', to: 'cn'),

  /// Simplified Chinese to Traditional Chinese (Hong Kong Standard).
  s2hk(from: 'cn', to: 'hk'),

  /// Traditional Chinese (Hong Kong Standard) to Simplified Chinese.
  hk2s(from: 'hk', to: 'cn'),

  /// Simplified Chinese to Traditional Chinese (Taiwan Standard).
  s2tw(from: 'cn', to: 'tw'),

  /// Traditional Chinese (Taiwan Standard) to Simplified Chinese.
  tw2s(from: 'tw', to: 'cn'),

  /// Simplified Chinese to Traditional Chinese (Taiwan Standard) with
  /// Taiwanese idiom.
  s2twp(from: 'cn', to: 'twp');

  const OptionPair({required this.from, required this.to});

  /// The source locale string passed to the opencc-js `Converter`.
  final String from;

  /// The target locale string passed to the opencc-js `Converter`.
  final String to;

  /// A lookup map from [ConverterOption.id] strings to their corresponding
  /// [OptionPair] values.
  static const Map<String, OptionPair> optionMap = {
    's2t': s2t,
    't2s': t2s,
    's2hk': s2hk,
    'hk2s': hk2s,
    's2tw': s2tw,
    'tw2s': tw2s,
    's2twp': s2twp
  };
}
