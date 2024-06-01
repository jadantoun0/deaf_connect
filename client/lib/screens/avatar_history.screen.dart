import 'dart:developer';
import 'package:deafconnect/daos/avatar_messages.dao.dart';
import 'package:deafconnect/models/avatar_message.model.dart';
import 'package:deafconnect/screens/loading.screen.dart';
import 'package:deafconnect/utils/colors.dart';
import 'package:deafconnect/utils/navigation_utils.dart';
import 'package:deafconnect/widgets/toasts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AvatarHistory extends StatefulWidget {
  const AvatarHistory({super.key});

  @override
  State<AvatarHistory> createState() => _AvatarHistoryState();
}

class _AvatarHistoryState extends State<AvatarHistory> {
  final ScrollController _scrollController = ScrollController();
  List<AvatarMessage> messages = [];
  int page = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _fetchedAll = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchMoreData();
    }
  }

  Future<void> _fetchMoreData() async {
    if (_isLoadingMore || _fetchedAll) {
      return;
    }
    setState(() {
      _isLoadingMore = true;
    });
    page++;
    final newMessages = await AvatarMessagesDAO.getMessages(page: page);
    messages += newMessages;
    // assuming 20 is the limit
    if (newMessages.length != 20) {
      _fetchedAll = true;
    }
    setState(() {
      _isLoadingMore = false;
    });
  }

  fetchData() async {
    messages = await AvatarMessagesDAO.getMessages(page: page);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreen();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: blackColor,
        ),
        title: const Text(
          'History',
          style: TextStyle(color: blackColor),
        ),
      ),
      body: messages.isEmpty
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No translated messages yet'),
              ],
            )
          : ListView.separated(
              controller: _scrollController,
              itemCount: messages.length + 1,
              itemBuilder: (context, index) {
                if (index >= messages.length) {
                  return _isLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Center(
                            child: CupertinoActivityIndicator(color: mainColor),
                          ),
                        )
                      : Container();
                }
                return ListTile(
                  title: Text(messages[index].message),
                  trailing: IntrinsicWidth(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            NavigationUtils.pop(
                              context,
                              message: messages[index].message,
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.play_circle,
                              color: mainColor,
                              size: 30,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            log('deleting');
                            CustomToast.showToast(context,
                                '${messages[index].message} has been deleted');
                            AvatarMessagesDAO.deleteMessage(messages[index].id);
                            messages.removeWhere(
                                (element) => element.id == messages[index].id);

                            setState(() {});
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.delete,
                              color: blackColor,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  height: 2,
                  color: secondaryColor,
                  width: double.infinity,
                );
              },
            ),
    );
  }
}
