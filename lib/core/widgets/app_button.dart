import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; 
  final bool isPrimary;
  final double width;
  final bool isLoading; 

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed, 
    this.isPrimary = true,
    this.width = double.infinity,
    this.isLoading = false, 
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? primaryColor : Colors.grey[200],
          foregroundColor: isPrimary ? Colors.white : Colors.black54,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: isPrimary ? 4 : 0,
          shadowColor: isPrimary ? primaryColor.withValues(alpha: 0.4) : Colors.transparent,
        ),
        onPressed: isLoading ? null : onPressed, 
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}