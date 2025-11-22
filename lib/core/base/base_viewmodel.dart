import 'package:flutter/foundation.dart';

/// Base ViewModel class with common state management functionality
abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  bool get isIdle => _state == ViewState.idle;
  bool get isLoading => _state == ViewState.loading;
  bool get isSuccess => _state == ViewState.success;
  bool get isError => _state == ViewState.error;
  bool get isEmpty => _state == ViewState.empty;

  /// Set the view state and notify listeners
  void setState(ViewState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Set loading state
  void setLoading() {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  /// Set success state
  void setSuccess() {
    _state = ViewState.success;
    _errorMessage = null;
    notifyListeners();
  }

  /// Set error state with message
  void setError(String message) {
    _state = ViewState.error;
    _errorMessage = message;
    notifyListeners();
  }

  /// Set empty state
  void setEmpty() {
    _state = ViewState.empty;
    _errorMessage = null;
    notifyListeners();
  }

  /// Set idle state
  void setIdle() {
    _state = ViewState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Execute an async operation with automatic state management
  Future<T?> executeAsync<T>({
    required Future<T> Function() operation,
    bool showLoading = true,
    Function(T result)? onSuccess,
    Function(String error)? onError,
  }) async {
    try {
      if (showLoading) setLoading();

      final result = await operation();

      setSuccess();
      onSuccess?.call(result);
      return result;
    } catch (e) {
      final errorMsg = e.toString();
      setError(errorMsg);
      onError?.call(errorMsg);
      return null;
    }
  }
}

/// Enum representing different states of a view
enum ViewState {
  idle,
  loading,
  success,
  error,
  empty,
}