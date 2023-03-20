import 'package:async_redux/async_redux.dart';
import 'package:client_chat/backend/actions/resolved_error_action.dart';
import 'package:client_chat/backend/models/encounted_error_model.dart';
import 'package:client_chat/backend/states/app_state.dart';
import 'package:client_chat/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTemplate extends StatefulWidget {
  AppTemplate({
    Key? key,
    required this.child,
    this.appBar,
    required this.isLoading,
    required this.appOn,
    required this.encountedError,
  }) : super(key: key);

  Widget child;
  AppBar? appBar;
  bool isLoading;
  bool appOn;
  EncountedError encountedError;

  @override
  State<AppTemplate> createState() => _AppTemplateState();
}

class _AppTemplateState extends State<AppTemplate> {
  @override
  Widget build(BuildContext context) {
    if (widget.encountedError.isValid()) {
      Future.delayed(
        Duration.zero,
        () => showErrorDialog(widget.encountedError.description),
      );
    }

    return Scaffold(
      appBar: widget.appBar,
      body: widget.isLoading
          ? Center(
              child: LoadingIndicator(
                loadingText: 'Please wait..',
              ),
            )
          : widget.appOn
              ? widget.child
              : _noSignalWidget(),
    );
  }

  Widget _noSignalWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Text('No Signal'),
          ),
          Image.asset('assets/images/no_signal.jpg'),
          Container(
            child: Text('Available on ___'),
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            child: Text('Exit'),
          )
        ],
      ),
    );
  }

  void showErrorDialog(String description) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(description),
            ElevatedButton(
              onPressed: () async {
                //  StoreProvider.dispatch<AppState>(context, ResolvedErrorAction());
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            )
          ],
        ),
      ),
    );
  }
}
