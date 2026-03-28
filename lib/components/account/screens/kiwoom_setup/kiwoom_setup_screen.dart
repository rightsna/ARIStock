import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import 'package:aristock/shared/theme.dart';
import 'widgets/setup_header.dart';
import 'widgets/api_key_form.dart';
import 'widgets/mock_investment_toggle.dart';
import 'widgets/setup_help_card.dart';

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
                const SetupHeader(),
                const SizedBox(height: 48),
                ApiKeyForm(
                  formKey: _formKey,
                  appKeyController: _appKeyController,
                  appSecretController: _appSecretController,
                  obscureKey: _obscureKey,
                  obscureSecret: _obscureSecret,
                  onToggleObscureKey: () =>
                      setState(() => _obscureKey = !_obscureKey),
                  onToggleObscureSecret: () =>
                      setState(() => _obscureSecret = !_obscureSecret),
                ),
                const SizedBox(height: 20),
                MockInvestmentToggle(
                  isMock: _isMock,
                  onChanged: (v) => setState(() => _isMock = v),
                ),
                const SizedBox(height: 28),
                _buildSubmitButton(),
                const SizedBox(height: 24),
                const SetupHelpCard(),
              ],
            ),
          ),
        ),
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
}
