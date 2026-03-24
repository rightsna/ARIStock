import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/account_provider.dart';
import '../../../shared/theme.dart';

/// 키움 API 키 입력 화면: App Key와 App Secret을 입력받습니다.
class ApiKeySetupScreen extends StatefulWidget {
  const ApiKeySetupScreen({super.key});

  @override
  State<ApiKeySetupScreen> createState() => _ApiKeySetupScreenState();
}

class _ApiKeySetupScreenState extends State<ApiKeySetupScreen>
    with SingleTickerProviderStateMixin {
  final _appKeyController = TextEditingController();
  final _appSecretController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureKey = true;
  bool _obscureSecret = true;
  bool _isSaving = false;
  bool _isMock = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _appKeyController.dispose();
    _appSecretController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _saveKeys() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<AccountProvider>();

    final error = await provider.connectAndFetchAccounts(
      _appKeyController.text.trim(),
      _appSecretController.text.trim(),
      isMock: _isMock,
    );

    if (mounted) {
      setState(() => _isSaving = false);

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 12),
                _buildSubtitle(),
                const SizedBox(height: 48),
                _buildForm(),
                const SizedBox(height: 20),
                _buildMockToggle(),
                const SizedBox(height: 28),
                _buildSubmitButton(),
                const SizedBox(height: 24),
                _buildHelpText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.vpn_key_rounded, color: AppTheme.textMain, size: 36),
    );
  }

  Widget _buildTitle() {
    return Text(
      '키움 API 연동',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textMain,
          ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      '실시간 포트폴리오 데이터를 가져오기 위해\n키움증권 Open API 인증 정보를 입력해주세요.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppTheme.textMain.withValues(alpha: 0.5),
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _appKeyController,
            label: 'App Key',
            hint: '키움 Open API App Key를 입력하세요',
            icon: Icons.key_rounded,
            obscure: _obscureKey,
            onToggleObscure: () => setState(() => _obscureKey = !_obscureKey),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _appSecretController,
            label: 'App Secret',
            hint: '키움 Open API App Secret을 입력하세요',
            icon: Icons.lock_rounded,
            obscure: _obscureSecret,
            onToggleObscure: () =>
                setState(() => _obscureSecret = !_obscureSecret),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textMain.withValues(alpha: 0.08)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: AppTheme.textMain, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: AppTheme.textMain54, fontSize: 14),
          hintStyle: TextStyle(
              color: AppTheme.textMain.withValues(alpha: 0.2), fontSize: 14),
          prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppTheme.textMain38,
              size: 20,
            ),
            onPressed: onToggleObscure,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label를 입력해주세요';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveKeys,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: AppTheme.textMain,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child:
                    CircularProgressIndicator(color: AppTheme.textMain, strokeWidth: 2),
              )
            : const Text(
                '연동 시작',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildMockToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isMock
            ? Colors.amber.withValues(alpha: 0.08)
            : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isMock
              ? Colors.amber.withValues(alpha: 0.3)
              : AppTheme.textMain.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isMock ? Icons.science_rounded : Icons.trending_up_rounded,
            color: _isMock ? Colors.amber : AppTheme.textMain38,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '모의투자',
                  style: TextStyle(
                    color: _isMock ? Colors.amber : AppTheme.textMain70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _isMock ? 'mockapi.kiwoom.com 사용' : '실전투자 (api.kiwoom.com)',
                  style: TextStyle(
                    color: AppTheme.textMain.withValues(alpha: 0.35),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isMock,
            onChanged: (v) => setState(() => _isMock = v),
            activeThumbColor: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildHelpText() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppTheme.primaryBlue, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '키움증권 Open API 홈페이지에서\nApp Key와 App Secret을 발급받을 수 있습니다.',
                      style: TextStyle(
                        color: AppTheme.textMain.withValues(alpha: 0.6),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => launchUrl(
                  Uri.parse('https://openapi.kiwoom.com/main/home'),
                  mode: LaunchMode.externalApplication,
                ),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.open_in_new_rounded,
                          color: AppTheme.primaryBlue, size: 14),
                      SizedBox(width: 8),
                      Text(
                        'openapi.kiwoom.com',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
