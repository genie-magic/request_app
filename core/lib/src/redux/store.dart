import 'package:redux/redux.dart';
import 'package:http/http.dart';
import 'package:key_value_store/key_value_store.dart';
import 'package:core/src/redux/app/app.state.dart';
import 'package:core/src/redux/app/app.reducer.dart';

Store<AppState> createStore(Client client, KeyValueStore keyValueStore) {
  return Store(
    appReducer,
    initialState: AppState.initial(),
    distinct: true,
    middleware: []
  );
}