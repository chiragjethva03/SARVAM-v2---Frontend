import 'package:flutter/material.dart';
import 'join_create_group_sheet.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                "Manage Group\nExpenses Effortlessly",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.05),

              // Empty state text
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No expenses added yet!",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Start tracking your trip costs now.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Add Trip button
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (_) => JoinCreateGroupSheet(
                            onJoinGroup: () {
                              Navigator.pop(context);
                              debugPrint("Join Group clicked");
                            },
                            onCreateNew: () {
                              Navigator.pop(context);
                              debugPrint("Create New clicked");
                            },
                          ),
                        );
                      },
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: const Color(0x1C2196F3), // #2196F3 @ 11% opacity
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).textTheme.bodyMedium?.color ??
                                Colors.black,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 30,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text("Add Trip", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
