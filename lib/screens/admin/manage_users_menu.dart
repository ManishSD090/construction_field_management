import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_erp/core/services/app_colors.dart';
import 'package:construction_erp/controllers/admin/user_controller.dart';
import 'package:construction_erp/controllers/admin/role_controller.dart';
import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/role.dart';
import 'create_role_screen.dart';
import 'create_user_screen.dart';
import 'user_info_screen.dart';
import 'role_info_screen.dart';

class ManageUsersMenuScreen extends ConsumerStatefulWidget {
  const ManageUsersMenuScreen({super.key});

  @override
  ConsumerState<ManageUsersMenuScreen> createState() =>
      _ManageUsersMenuScreenState();
}

class _ManageUsersMenuScreenState extends ConsumerState<ManageUsersMenuScreen> {
  String activeTab = "Users";
  bool isDeleteMode = false;
  bool isRolesDeleteMode = false;

  // Selection sets store IDs instead of indices for better data integrity
  Set<String> selectedUserIds = {};
  Set<String> selectedRoleIds = {};

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    Future.microtask(() {
      ref.read(userControllerProvider.notifier).fetchUsers();
      ref.read(roleControllerProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);
    final roleState = ref.watch(roleControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text(
          "Manage Users and Roles",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildToggleSwitch(),
          _buildSearchBar(),
          if (activeTab == "Users")
            _buildUsersHeader()
          else
            _buildRolesHeader(),
          Expanded(
            child: activeTab == "Users"
                ? _buildUsersContent(userState)
                : _buildRolesContent(roleState),
          ),
        ],
      ),
      floatingActionButton: _buildDynamicFAB(),
    );
  }

  // --- Content Builders with Refresh Indicators ---

  Widget _buildUsersContent(AsyncValue<UserState> userState) {
    return userState.when(
      data: (state) => RefreshIndicator(
        onRefresh: () => ref.read(userControllerProvider.notifier).refresh(),
        color: AppColors.primaryBlue,
        child: _buildUsersListView(state),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => RefreshIndicator(
        onRefresh: () => ref.read(userControllerProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 16),
                  Text("Error fetching users: $err"),
                  const SizedBox(height: 8),
                  const Text("Pull down to retry",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRolesContent(AsyncValue<RoleState> roleState) {
    return roleState.when(
      data: (state) => RefreshIndicator(
        onRefresh: () => ref.read(roleControllerProvider.notifier).refresh(),
        color: AppColors.primaryBlue,
        child: _buildRolesGridView(state),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => RefreshIndicator(
        onRefresh: () => ref.read(roleControllerProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 16),
                  Text("Error fetching roles: $err"),
                  const SizedBox(height: 8),
                  const Text("Pull down to retry",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Header Helpers ---

  Widget _buildUsersHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          const Text("Users List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() {
              isDeleteMode = !isDeleteMode;
              selectedUserIds.clear();
            }),
            icon: Icon(isDeleteMode ? Icons.close : Icons.delete,
                color: Colors.red),
            style: IconButton.styleFrom(backgroundColor: Colors.red.shade50),
          ),
          const SizedBox(width: 8),
          _buildFilterBtn(),
        ],
      ),
    );
  }

  Widget _buildFilterBtn() {
    return PopupMenuButton<String>(
      onSelected: (String status) {
        ref.read(userControllerProvider.notifier).fetchUsers(
              status: status == 'all' ? null : status,
            );
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(value: 'all', child: Text("All Users")),
        const PopupMenuItem(value: 'active', child: Text("Active Only")),
        const PopupMenuItem(value: 'inactive', child: Text("Inactive Only")),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBlue),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Text(
              "Filter By ",
              style: TextStyle(fontSize: 12, color: AppColors.primaryBlue),
            ),
            Icon(Icons.tune, size: 16, color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildRolesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Roles Created",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => setState(() {
              isRolesDeleteMode = !isRolesDeleteMode;
              selectedRoleIds.clear();
            }),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: isRolesDeleteMode ? Colors.grey : Colors.red,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(
                  isRolesDeleteMode ? Icons.close : Icons.delete_outline,
                  color: Colors.white,
                  size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // --- ListView Builders ---

  Widget _buildUsersListView(UserState state) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          ref.read(userControllerProvider.notifier).loadMoreUsers();
        }
        return false;
      },
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
        padding: const EdgeInsets.all(16),
        itemCount: state.userList.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.userList.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final user = state.userList[index];
          bool isSelected = selectedUserIds.contains(user.id);

          return _buildUserTile(user, isSelected);
        },
      ),
    );
  }

  Widget _buildUserTile(User user, bool isSelected) {
    final projectCount = user.stats?.projects ?? 0;

    return GestureDetector(
      onTap: () {
        if (isDeleteMode) {
          setState(() => isSelected
              ? selectedUserIds.remove(user.id)
              : selectedUserIds.add(user.id));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => UserInfoScreen(
                        userId: user.id,
                      )));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? Colors.red : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: isDeleteMode
              ? Checkbox(
                  value: isSelected,
                  activeColor: Colors.red,
                  onChanged: (v) => setState(() => v!
                      ? selectedUserIds.add(user.id)
                      : selectedUserIds.remove(user.id)),
                )
              : null,
          title: Text(user.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text("Role: ${user.role?.name ?? 'Employee'}",
                  style: const TextStyle(color: Colors.blue, fontSize: 13)),
              Row(
                children: [
                  const Icon(Icons.assignment_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "Projects Assigned: ",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  Text(
                    "$projectCount",
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusBadge(user.isActive),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.teal.shade400 : Colors.red.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRolesGridView(RoleState state) {
    return GridView.builder(
      physics:
          const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: state.roles.length,
      itemBuilder: (context, index) {
        final role = state.roles[index];
        bool isSelected = selectedRoleIds.contains(role.id);

        return GestureDetector(
          onTap: () {
            if (isRolesDeleteMode) {
              setState(() => isSelected
                  ? selectedRoleIds.remove(role.id)
                  : selectedRoleIds.add(role.id));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RoleInfoScreen(roleId: role.id)));
            }
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isSelected ? Colors.red : Colors.grey.shade100,
                      width: isSelected ? 2 : 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(role.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1),
                    const SizedBox(height: 8),
                    Text("Assigned Users: ${role.stats?['users'] ?? 0}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.blue)),
                  ],
                ),
              ),
              if (isRolesDeleteMode)
                Positioned(
                    top: 4,
                    right: 4,
                    child: Checkbox(
                      value: isSelected,
                      activeColor: Colors.red,
                      shape: const CircleBorder(),
                      onChanged: (v) => setState(() => v!
                          ? selectedRoleIds.add(role.id)
                          : selectedRoleIds.remove(role.id)),
                    )),
            ],
          ),
        );
      },
    );
  }

  // --- Dynamic FAB for Bulk Deletion ---

  Widget _buildDynamicFAB() {
    if (activeTab == "Users" && isDeleteMode && selectedUserIds.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: () async {
          await ref
              .read(userControllerProvider.notifier)
              .bulkDeleteUsers(selectedUserIds.toList());
          setState(() {
            isDeleteMode = false;
            selectedUserIds.clear();
          });
        },
        backgroundColor: Colors.red,
        label: const Text("Delete Selected",
            style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.delete, color: Colors.white),
      );
    }

    if (activeTab == "Roles" &&
        isRolesDeleteMode &&
        selectedRoleIds.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: () async {
          await ref
              .read(roleControllerProvider.notifier)
              .bulkDeleteRoles(selectedRoleIds.toList());
          setState(() {
            isRolesDeleteMode = false;
            selectedRoleIds.clear();
          });
        },
        backgroundColor: Colors.red,
        label:
            const Text("Delete Roles", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.delete, color: Colors.white),
      );
    }

    return FloatingActionButton(
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (c) => activeTab == "Roles"
                  ? const CreateRoleScreen()
                  : const CreateUserScreen())),
      backgroundColor: AppColors.primaryBlue,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          if (activeTab == "Users") {
            ref.read(userControllerProvider.notifier).fetchUsers(search: value);
          } else {
            ref.read(roleControllerProvider.notifier).refresh(search: value);
          }
        },
        decoration: InputDecoration(
          hintText: "Search $activeTab",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 45,
      decoration: BoxDecoration(
          color: const Color(0xFFE9F2FE),
          borderRadius: BorderRadius.circular(30)),
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
        _searchController.clear();
        // Trigger a fresh fetch for the newly active tab
        if (t == "Users") {
          ref.read(userControllerProvider.notifier).refresh();
        } else {
          ref.read(roleControllerProvider.notifier).refresh();
        }
      }),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: isA ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(30)),
        child: Text(t,
            style: TextStyle(
                color: isA ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
