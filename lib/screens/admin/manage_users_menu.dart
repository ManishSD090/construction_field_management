import 'package:flutter/material.dart';
import '../../core/services/app_colors.dart';
import 'create_role_screen.dart';
import 'create_user_screen.dart'; 
import 'user_info_screen.dart'; 
import 'role_info_screen.dart';

class ManageUsersMenuScreen extends StatefulWidget {
  const ManageUsersMenuScreen({super.key});

  @override
  State<ManageUsersMenuScreen> createState() => _ManageUsersMenuScreenState();
}

class _ManageUsersMenuScreenState extends State<ManageUsersMenuScreen> {
  // --- States ---
  String activeTab = "Users";
  bool isDeleteMode = false; // For Users
  bool isRolesDeleteMode = false; // For Roles
  Set<int> selectedIndices = {}; // For Users
  Set<int> selectedRoleIndices = {}; // For Roles
  
  // Search State
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, String>> usersList = [
    {
      "id": "SYS-001",
      "name": "Sample Name",
      "role": "Manager",
      "project": "Sample Project 1",
      "status": "Active",
      "email": "sample@abc.com",
      "phone": "+91 98765 43210",
      "aadhar": "1234 5678 9012"
    },
    {
      "id": "SYS-002",
      "name": "Sample Name",
      "role": "Manager",
      "project": "Sample Project 2",
      "status": "Active",
      "email": "manager@abc.com",
      "phone": "+91 98765 43211",
      "aadhar": "9876 5432 1098"
    },
    {
      "id": "SYS-003",
      "name": "John Doe",
      "role": "Engineer",
      "project": "Metro Line 5",
      "status": "Inactive",
      "email": "john.doe@abc.com",
      "phone": "+91 98765 43212",
      "aadhar": "1122 3344 5566"
    },
  ];

  final List<Map<String, dynamic>> rolesList = [
    {"name": "Manager", "count": 6},
    {"name": "Site Engineer", "count": 32},
    {"name": "Supervisor", "count": 22},
    {"name": "Staff", "count": 134},
    {"name": "Custom Role", "count": 64},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Filter Helpers ---
  List<Map<String, String>> get _filteredUsers {
    if (_searchQuery.isEmpty) return usersList;
    return usersList.where((u) => 
      u['name']!.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  List<Map<String, dynamic>> get _filteredRoles {
    if (_searchQuery.isEmpty) return rolesList;
    return rolesList.where((r) => 
      r['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Manage Users and Roles",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Toggle Switch (Moved to top)
          const SizedBox(height: 16),
          _buildToggleSwitch(),
          
          // 2. Search Bar (Moved below Toggle)
          _buildSearchBar(),

          if (activeTab == "Users") _buildUsersHeader() else _buildRolesHeader(),

          Expanded(
            child: activeTab == "Users" 
              ? _buildUsersListView() 
              : _buildRolesGridView(),
          ),
        ],
      ),
      floatingActionButton: _buildDynamicFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // --- Header Helpers ---

  Widget _buildRolesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Roles Created", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
            ],
          ),
          GestureDetector(
            onTap: () => setState(() {
              isRolesDeleteMode = !isRolesDeleteMode;
              selectedRoleIndices.clear();
            }),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isRolesDeleteMode ? Colors.grey : Colors.red,
                borderRadius: BorderRadius.circular(8)
              ),
              child: Icon(isRolesDeleteMode ? Icons.close : Icons.delete_outline, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // --- Grid/List Helpers ---

Widget _buildRolesGridView() {
    final currentRoles = _filteredRoles;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: currentRoles.length,
      itemBuilder: (context, index) {
        final role = currentRoles[index];
        bool isSelected = selectedRoleIndices.contains(index);

        return GestureDetector(
          onTap: () {
            if (isRolesDeleteMode) {
              setState(() {
                isSelected ? selectedRoleIndices.remove(index) : selectedRoleIndices.add(index);
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoleInfoScreen(roleData: role),
                ),
              );
            }
          },
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.red : Colors.grey.shade100,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                // 🎯 Updated Child: Row with Expanded Content + Arrow
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            role['name'], 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              children: [
                                const TextSpan(text: "Assigned Users: "),
                                TextSpan(
                                  text: "${role['count']}", 
                                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                  ],
                ),
              ),
              if (isRolesDeleteMode)
                Positioned(
                  top: 4, right: 4,
                  child: Checkbox(
                    value: isSelected,
                    activeColor: Colors.red,
                    shape: const CircleBorder(),
                    onChanged: (v) => setState(() => v! ? selectedRoleIndices.add(index) : selectedRoleIndices.remove(index)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // --- FAB Logic ---

  Widget _buildDynamicFAB() {
    // Logic for Roles Delete
    if (activeTab == "Roles" && isRolesDeleteMode && selectedRoleIndices.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            // Identify roles to delete from the filtered view
            final rolesToDelete = selectedRoleIndices.map((i) => _filteredRoles[i]).toList();
            // Remove them from the master list
            rolesList.removeWhere((element) => rolesToDelete.contains(element));
            isRolesDeleteMode = false;
            selectedRoleIndices.clear();
          });
        },
        backgroundColor: Colors.red,
        label: const Text("Delete Selected Roles", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.delete, color: Colors.white),
      );
    }

    // Logic for Users Delete (Fixed Logic)
    if (activeTab == "Users" && isDeleteMode && selectedIndices.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: () => setState(() { 
           // Identify users to delete from the filtered view
           final usersToDelete = selectedIndices.map((i) => _filteredUsers[i]).toList();
           // Remove them from the master list
           usersList.removeWhere((element) => usersToDelete.contains(element));
           isDeleteMode = false; 
           selectedIndices.clear(); 
        }),
        backgroundColor: Colors.red,
        label: const Text("Delete Selected Users", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.delete, color: Colors.white),
      );
    }

    // Standard FAB (Create Logic)
    return FloatingActionButton(
      onPressed: () {
        if (activeTab == "Roles") {
           // Go to Create Role
           Navigator.push(context, MaterialPageRoute(builder: (c) => const CreateRoleScreen()));
        } else if (activeTab == "Users") {
           // Go to Create User (Placeholder for now as file not provided)
            Navigator.push(context, MaterialPageRoute(builder: (c) => const CreateUserScreen()));
           
        }
      },
      backgroundColor: AppColors.primaryBlue,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  // --- UI Components ---

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Slight adjustment for spacing
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: activeTab == "Users" ? "Search Users" : "Search Roles", // Dynamic hint
          prefixIcon: const Icon(Icons.search),
          suffixIcon: const Icon(Icons.mic),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 45,
      decoration: BoxDecoration(color: const Color(0xFFE9F2FE), borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Expanded(child: _toggleBtn("Users")),
          Expanded(child: _toggleBtn("Roles")),
        ],
      ),
    );
  }

  Widget _toggleBtn(String t) {
    bool isA = activeTab == t;
    return GestureDetector(
      onTap: () => setState(() { 
        activeTab = t; 
        isDeleteMode = false; 
        isRolesDeleteMode = false;
        _searchQuery = ""; // Clear search on tab switch
        _searchController.clear();
        selectedIndices.clear();
        selectedRoleIndices.clear();
      }),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(color: isA ? AppColors.primaryBlue : Colors.transparent, borderRadius: BorderRadius.circular(30)),
        child: Text(t, style: TextStyle(color: isA ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildUsersHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          const Text("Users List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() { isDeleteMode = !isDeleteMode; selectedIndices.clear(); }),
            icon: Icon(isDeleteMode ? Icons.close : Icons.delete, color: Colors.red),
            style: IconButton.styleFrom(backgroundColor: Colors.red.shade50),
          ),
          const SizedBox(width: 8),
          _filterBtn(),
        ],
      ),
    );
  }

  Widget _filterBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBlue), borderRadius: BorderRadius.circular(20)),
      child: const Row(children: [Text("Filter By ", style: TextStyle(fontSize: 12)), Icon(Icons.tune, size: 16)]),
    );
  }

Widget _buildUsersListView() {
    final currentUsers = _filteredUsers;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: currentUsers.length,
      itemBuilder: (context, index) {
        final data = currentUsers[index];
        bool isSel = selectedIndices.contains(index);

        return GestureDetector(
          onTap: () {
            if (isDeleteMode) {
              setState(() {
                isSel ? selectedIndices.remove(index) : selectedIndices.add(index);
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserInfoScreen(
                    name: data['name'] ?? "Unknown",
                    email: data['email'] ?? "No Email",
                    phone: data['phone'] ?? "No Phone",
                    role: data['role'] ?? "No Role",
                    userId: data['id'] ?? "N/A",
                    aadharNumber: data['aadhar'] ?? "N/A",
                  ),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSel ? Colors.red : Colors.grey.shade200, 
                width: isSel ? 1.5 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: isDeleteMode
                  ? Checkbox(
                      value: isSel,
                      activeColor: Colors.red,
                      shape: const CircleBorder(),
                      onChanged: (v) => setState(() => v!
                          ? selectedIndices.add(index)
                          : selectedIndices.remove(index)),
                    )
                  : null,
              title: Text(
                data['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    "Role: ${data['role']}",
                    style: const TextStyle(color: Colors.blue, fontSize: 13),
                  ),
                  Text(
                    "Project Name: ${data['project']}",
                    style: const TextStyle(color: Colors.blue, fontSize: 13),
                  ),
                ],
              ),
              // 🎯 Updated Trailing: Status + Arrow
              trailing: Row(
                mainAxisSize: MainAxisSize.min, // Keep minimal width
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: data['status'] == "Active"
                          ? Colors.teal.shade400
                          : Colors.red.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      data['status']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8), // Spacing between status and arrow
                  const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}