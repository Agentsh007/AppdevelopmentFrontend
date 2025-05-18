import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
import 'dart:convert';

class DonorWithdrawScreen extends StatefulWidget {
  const DonorWithdrawScreen({super.key});

  @override
  _DonorWithdrawScreenState createState() => _DonorWithdrawScreenState();
}

class _DonorWithdrawScreenState extends State<DonorWithdrawScreen> {
  bool _isLoading = false;

  Future<void> _withdrawDonor() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.user?.token;
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/bloodbank/donor/withdraw/'),
        headers: {'Authorization': 'Token $token'},
      );
      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donor profile withdrawn successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonDecode(response.body)['message'] ?? 'Withdrawal failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Are you sure you want to withdraw as a donor?'),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _withdrawDonor,
                    child: const Text('Withdraw'),
                  ),
          ],
        ),
      ),
    );
  }
}