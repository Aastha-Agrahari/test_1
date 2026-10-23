
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user_model.dart';

void main() {
  runApp(const EmployeeApp());
}

class EmployeeApp extends StatelessWidget {
  const EmployeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Directory',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const EmployeeListScreen(),
    );
  }
}

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() =>
      _EmployeeListScreenState();
}

class _EmployeeListScreenState
    extends State<EmployeeListScreen> {
  List<UserModel> employees = [];
  List<UserModel> filteredEmployees = [];

  bool isLoading = true;
  String? errorMessage;

  final TextEditingController searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  // Fetch employees from API
  Future<void> fetchEmployees() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://jsonplaceholder.typicode.com/users',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData =
        jsonDecode(response.body);

        final List<UserModel> employeeList = jsonData
            .map(
              (json) => UserModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
            .toList();

        if (!mounted) return;

        setState(() {
          employees = employeeList;
          filteredEmployees = employeeList;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        throw Exception('Failed to load employees');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to fetch employees.';
      });
    }
  }

  // Search employees by name
  void searchEmployees(String query) {
    final results = employees.where((employee) {
      return employee.name
          .toLowerCase()
          .contains(query.trim().toLowerCase());
    }).toList();

    setState(() {
      filteredEmployees = results;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Employee Directory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: searchEmployees,
              decoration: InputDecoration(
                hintText: 'Search employee by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    searchEmployees('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : errorMessage != null
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(errorMessage!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });
                        fetchEmployees();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
                  : filteredEmployees.isEmpty
                  ? const Center(
                child: Text('No employees found.'),
              )
                  : ListView.builder(
                itemCount: filteredEmployees.length,
                itemBuilder: (context, index) {
                  final UserModel employee =
                  filteredEmployees[index];

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                        Colors.blue.shade100,
                        child: Text(
                          employee.name.isNotEmpty
                              ? employee.name[0]
                              .toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        employee.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding:
                        const EdgeInsets.only(
                          top: 8,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.email,
                                  size: 16,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Expanded(
                                  child: Text(
                                    employee.email,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 16,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Expanded(
                                  child: Text(
                                    employee.phone,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
