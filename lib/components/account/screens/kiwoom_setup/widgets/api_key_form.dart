import 'package:flutter/material.dart';
import 'package:aristock/shared/theme.dart';

class ApiKeyForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController appKeyController;
  final TextEditingController appSecretController;
  final bool obscureKey;
  final bool obscureSecret;
  final VoidCallback onToggleObscureKey;
  final VoidCallback onToggleObscureSecret;

  const ApiKeyForm({
    super.key,
    required this.formKey,
    required this.appKeyController,
    required this.appSecretController,
    required this.obscureKey,
    required this.obscureSecret,
    required this.onToggleObscureKey,
    required this.onToggleObscureSecret,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: appKeyController,
            label: 'App Key',
            hint: '키움 Open API App Key를 입력하세요',
            icon: Icons.key_rounded,
            obscure: obscureKey,
            onToggleObscure: onToggleObscureKey,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: appSecretController,
            label: 'App Secret',
            hint: '키움 Open API App Secret을 입력하세요',
            icon: Icons.lock_rounded,
            obscure: obscureSecret,
            onToggleObscure: onToggleObscureSecret,
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
}
