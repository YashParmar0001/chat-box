import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:chat_box/controller/auth_controller.dart';
import 'package:chat_box/model/group_model.dart';
import 'package:chat_box/repositories/group_repository.dart';
import 'package:get/get.dart';

class GroupsController extends GetxController {
  final _groups = <Group>[].obs;
  final _userGroups = <Group>[].obs;

  List<Group> get groups => _groups;

  List<Group> get userGroups => _userGroups;

  final _isLoading = true.obs;

  bool get isLoading => _isLoading.value;

  final _isCreatingGroup = false.obs;

  final _isUpdatingGroup = false.obs;

  bool get isCreatingGroup => _isCreatingGroup.value;

  bool get isUpdatingGroup => _isUpdatingGroup.value;

  final groupsRepository = GroupRepository();
  StreamSubscription? _groupsSubscription;

  @override
  void onClose() {
    _groupsSubscription?.cancel();
    super.onClose();
  }

  void getGroups() {
    _groupsSubscription = groupsRepository.getGroups().listen((groups) {
      dev.log('Groups snapshot: $groups', name: 'Group');
      final email = Get.find<AuthController>().email!;
      _groups.value = groups;
      dev.log('All groups: $groups');
      _userGroups.value =
          groups.where((e) => e.memberIds.contains(email)).toList();
      dev.log('User groups: $userGroups');
    });
  }

  Future<void> createGroup({
    required String name,
    required String description,
    File? image,
    required String userId,
    required List<String> users,
  }) async {
    _isCreatingGroup.value = true;
    try {
      final group = Group(
        id: '',
        name: name,
        description: description.isEmpty ? 'No description' : description,
        createdByUserId: userId,
        memberIds: users..add(userId),
      );

      await groupsRepository.createGroup(
        group: group,
        groupProfile: image,
      );
      Get.back();
      Get.snackbar('Groups', 'Group created successfully!');
    } catch (e) {
      dev.log('Got error: $e', name: 'Group');
      Get.snackbar('Groups', 'Something went wrong!');
    }
    _isCreatingGroup.value = false;
  }

  Future<void> deleteGroup({required String id}) async {
    try {
      await groupsRepository.deleteGroup(groupId: id);
      Get.back();
      Get.back();
      Get.snackbar('Groups', 'Group deleted successfully!');
    } catch (e) {
      dev.log('Got error: $e', name: 'Group');
      Get.snackbar('Groups', 'Something went wrong!');
    }
  }

  Future<void> updateGroup({
    required String id,
    required String name,
    required String description,
    File? image,
  }) async {
    _isUpdatingGroup.value = true;
    try {
      await groupsRepository.updateGroup(
        id: id,
        name: name,
        description: description,
        groupProfile: image,
      );
      Get.back();
      Get.snackbar('Groups', 'Group updated successfully!');
    } catch (e) {
      dev.log('Got error: $e', name: 'Group');
      Get.snackbar('Groups', 'Something went wrong!');
    }
    _isUpdatingGroup.value = false;
  }

  void closeSubscriptions() {
    _groups.value = [];
    _groupsSubscription?.cancel();
  }
}
