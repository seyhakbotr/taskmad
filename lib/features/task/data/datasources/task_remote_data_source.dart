import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskmanage/core/error/exceptions.dart';
import 'package:taskmanage/features/task/data/models/task_model.dart';
import 'package:taskmanage/features/task/domain/entities/topic.dart';

abstract interface class TaskRemoteDataSource {
  Future<TaskModel> uploadTask(TaskModel task);
  Future<List<TaskModel>> getUserTasks(
      {List<String>? topicIds, required String userId});
  Future<void> deleteTask(String taskId);
  Future<String> uploadTaskImage({
    required File image,
    required TaskModel task,
  });
  Future<void> insertTaskTopic(
      {required String taskId, required String topicId});
  Future<TaskModel> updateTask(TaskModel task);

  Future<List<Topic>> getAllTaskTopics();
  Future<void> updateTaskTopics(String taskId, List<Topic> topics);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final SupabaseClient supabaseClient;

  TaskRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await supabaseClient.from('tasks').delete().eq('id', taskId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TaskModel>> getUserTasks({
    required String userId,
    List<String>? topicIds,
  }) async {
    try {
      final List<String> topicIdArray = topicIds ?? [];
      final response = await supabaseClient.rpc('get_user_tasks', params: {
        'user_id': userId,
        'input_topic_ids': topicIdArray.isEmpty ? null : topicIdArray,
      });

      if (response is List<dynamic>) {
        return response.map<TaskModel>((task) {
          return TaskModel.fromJson({
            ...task,
            'topics': (task['topics'] as List<dynamic>?)
                    ?.map((topicId) => topicId as String)
                    .toList() ??
                [],
          });
        }).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final taskData = await supabaseClient
          .from('tasks')
          .update(task.toJson())
          .eq('id', task.id!)
          .select();
      if (taskData.isEmpty) {
        throw ServerException("No task data returned after update");
      }
      return TaskModel.fromJson(taskData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TaskModel> uploadTask(TaskModel task) async {
    try {
      final taskData =
          await supabaseClient.from('tasks').insert(task.toJson()).select();
      return TaskModel.fromJson(taskData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadTaskImage(
      {required File image, required TaskModel task}) async {
    try {
      final uniqueId = '${task.id}_${DateTime.now().millisecondsSinceEpoch}';
      await supabaseClient.storage.from('tasks-image').upload(uniqueId, image);
      return supabaseClient.storage.from('tasks-image').getPublicUrl(uniqueId);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> insertTaskTopic(
      {required String taskId, required String topicId}) async {
    try {
      await supabaseClient.from('task_topics').insert({
        'task_id': taskId,
        'topic_id': topicId,
      });
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateTaskTopics(String taskId, List<Topic> topics) async {
    try {
      await supabaseClient.from('task_topics').delete().eq('task_id', taskId);

      final topicEntries = topics.map((topic) {
        return {
          'task_id': taskId,
          'topic_id': topic.id,
        };
      }).toList();

      await supabaseClient.from('task_topics').insert(topicEntries);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Topic>> getAllTaskTopics() async {
    try {
      final response = await supabaseClient
          .from('topics')
          .select('id, name,color')
          .order('name', ascending: true);

      return (response as List<dynamic>).map((topic) {
        return Topic(
          id: topic['id'] as String,
          name: topic['name'] as String,
          color: topic['color'] as String,
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
