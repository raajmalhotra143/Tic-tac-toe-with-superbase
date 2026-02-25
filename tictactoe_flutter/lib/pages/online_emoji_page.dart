import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme.dart';
import '../widgets/emoji_picker.dart';
import '../widgets/toast.dart';

class OnlineEmojiPage extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String emoji, String mode, String code) onConfirm;

  const OnlineEmojiPage({
    super.key,
    required this.onBack,
    required this.onConfirm,
  });

  @override
  State<OnlineEmojiPage> createState() => _OnlineEmojiPageState();
}

class _OnlineEmojiPageState extends State<OnlineEmojiPage> {
  String _selected = '🦁';
  String _tab = 'pick'; // 'pick' | 'join'
  String _roomCode = '';
  bool _showScanner = false;
  String _error = '';
  final _toast = ToastController();
  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _toast.bind(setState);
    _codeCtrl.addListener(() {
      final val = _codeCtrl.text.toUpperCase().replaceAll(
        RegExp(r'[^A-Z0-9]'),
        '',
      );
      if (val.length > 6) {
        _codeCtrl.text = val.substring(0, 6);
        _codeCtrl.selection = TextSelection.collapsed(offset: 6);
      }
      setState(() {
        _roomCode = _codeCtrl.text;
        _error = '';
      });
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _go(String mode, {String code = ''}) {
    if (_selected.isEmpty) {
      setState(() => _error = 'Pick an emoji first!');
      return;
    }
    setState(() => _error = '');
    widget.onConfirm(_selected, mode, code);
  }

  void _handleCodeJoin() {
    if (_roomCode.length != 6) {
      setState(() => _error = 'Enter a valid 6-character code');
      return;
    }
    _go('code', code: _roomCode);
  }

  void _handleScanSuccess(String code) {
    setState(() => _showScanner = false);
    if (code.isEmpty || code.length < 4) {
      _toast.show('Could not read a valid room code from QR');
      return;
    }
    final clean =
        code.substring(0, code.length < 6 ? code.length : 6).toUpperCase();
    _codeCtrl.text = clean;
    setState(() {
      _roomCode = clean;
      _tab = 'join';
    });
    _toast.show('📷 Scanned! Code: $clean');
  }

  @override
  Widget build(BuildContext context) {
    if (_showScanner) {
      return _QRScannerPage(
        onScan: _handleScanSuccess,
        onClose: () => setState(() => _showScanner = false),
      );
    }

    return AppPage(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButton2(onTap: widget.onBack),
                const SizedBox(height: 16),
                const Text('🌐 Online Mode', style: AppTextStyles.title),
                const SizedBox(height: 6),
                const Text(
                  'Choose your emoji, then join or create a game',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 20),

                // Emoji picker
                EmojiPicker(
                  selected: _selected,
                  onSelect: (e) => setState(() => _selected = e),
                ),
                const SizedBox(height: 20),

                // Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      _Tab(
                        label: '🎮 Create / Quick',
                        active: _tab == 'pick',
                        onTap:
                            () => setState(() {
                              _tab = 'pick';
                              _error = '';
                            }),
                      ),
                      _Tab(
                        label: '🔑 Join Room',
                        active: _tab == 'join',
                        onTap:
                            () => setState(() {
                              _tab = 'join';
                              _error = '';
                            }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tab content
                if (_tab == 'pick') ...[
                  GlowButton(
                    text: '🏠 Create Room & Get Code',
                    onTap: () => _go('create'),
                    block: true,
                  ),
                  const SizedBox(height: 10),
                  GlowButton(
                    text: '⚡ Quick Match (Auto)',
                    onTap: () => _go('quick'),
                    ghost: true,
                    block: true,
                  ),
                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _error,
                        style: const TextStyle(
                          color: AppColors.pink,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],

                if (_tab == 'join') ...[
                  // Scan QR button
                  GlowButton(
                    text: '📷 Scan QR Code',
                    onTap: () => setState(() => _showScanner = true),
                    color: AppColors.cyan,
                    block: true,
                  ),
                  const SizedBox(height: 12),
                  // OR divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.border)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter the 6-character room code',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Code input
                  TextField(
                    controller: _codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 12,
                      color: AppColors.cyan,
                    ),
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: 'XY2K9R',
                      hintStyle: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 24,
                        letterSpacing: 8,
                      ),
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.surface2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.cyan,
                          width: 2,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _handleCodeJoin(),
                  ),
                  const SizedBox(height: 8),
                  // Code dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      6,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 10,
                        height: 4,
                        decoration: BoxDecoration(
                          color:
                              i < _roomCode.length
                                  ? AppColors.cyan
                                  : AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _error,
                        style: const TextStyle(
                          color: AppColors.pink,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 12),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _roomCode.length == 6 ? 1.0 : 0.5,
                    child: GlowButton(
                      text: '→ Join Game',
                      onTap: _roomCode.length == 6 ? _handleCodeJoin : null,
                      block: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ToastOverlay(message: _toast.message),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

// ── QR Scanner page ────────────────────────────────────────────────────────
class _QRScannerPage extends StatefulWidget {
  final void Function(String) onScan;
  final VoidCallback onClose;

  const _QRScannerPage({required this.onScan, required this.onClose});

  @override
  State<_QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<_QRScannerPage> {
  bool _scanned = false;
  late MobileScannerController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = MobileScannerController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;
    _scanned = true;
    final val = barcode!.rawValue!;
    // Extract code from URL if it's a join link
    final match = RegExp(
      r'#join[=:]([A-Z0-9]{6})',
      caseSensitive: false,
    ).firstMatch(val);
    final code = match?.group(1) ?? val;
    widget.onScan(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _ctrl, onDetect: _onDetect),
          // Overlay
          Positioned.fill(
            child: CustomPaint(painter: _ScannerOverlayPainter()),
          ),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Scan QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              'Point camera at the QR code',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withAlpha(140);
    final center = Offset(size.width / 2, size.height / 2);
    const boxSize = 240.0;
    final rect = Rect.fromCenter(
      center: center,
      width: boxSize,
      height: boxSize,
    );

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, rect.top), paint);
    canvas.drawRect(
      Rect.fromLTWH(0, rect.bottom, size.width, size.height - rect.bottom),
      paint,
    );
    canvas.drawRect(Rect.fromLTWH(0, rect.top, rect.left, boxSize), paint);
    canvas.drawRect(
      Rect.fromLTWH(rect.right, rect.top, size.width - rect.right, boxSize),
      paint,
    );

    // Corner guides
    final guide =
        Paint()
          ..color = AppColors.cyan
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
    const g = 24.0;
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(g, 0), guide);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, g), guide);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(-g, 0), guide);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, g), guide);
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(g, 0),
      guide,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(0, -g),
      guide,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(-g, 0),
      guide,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(0, -g),
      guide,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
