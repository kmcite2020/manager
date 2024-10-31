import 'manager.dart';

class Navigation {
  final int limit;
  final Widget home;
  // Constructor with a default limit and a required default page
  Navigation({
    this.limit = 10,
    required this.home,
  }) {}

  // RM to manage the state of the navigation history
  late final navigationRM = Sparkle(
    <Widget>[home], // Use a list to track navigation history
  );

  // Getter for the navigation history
  List<Widget> get history => navigationRM.state;

  // Easier navigation
  void call([Widget? _widget]) {
    if (_widget != null) {
      to(_widget);
    } else {
      back();
    }
  }

  // Method to navigate to a new page and maintain the history limit
  void to(Widget widget) {
    final currentHistory = List<Widget>.from(navigationRM.state);

    // If history exceeds the limit, remove the oldest entry
    if (currentHistory.length >= limit) {
      currentHistory.removeAt(0);
    }

    // Add the new page to the history
    currentHistory.add(widget);

    // Update the reactive model state with the new history
    navigationRM.state = currentHistory;
  }

  // Method to navigate back (remove the current page from the stack)
  void back() {
    final currentHistory = List<Widget>.from(navigationRM.state);

    if (currentHistory.length > 1) {
      currentHistory.removeLast(); // Remove the last page (current page)
      navigationRM.state = currentHistory; // Update the state
    }
  }

  // Get the previous page, safely handling edge cases
  Widget oldWidget() {
    final currentHistory = navigationRM.state;
    if (currentHistory.length > 1) {
      return currentHistory[
          currentHistory.length - 2]; // Return the second-to-last page
    }
    return home; // Return defaultPage if no previous page exists
  }

  // Get the current page (never returns null)
  Widget widget() {
    final currentHistory = navigationRM.state;
    if (currentHistory.isNotEmpty) {
      return currentHistory.last; // Return the last page in the history
    }
    return home; // Fall back to the default page if the history is empty
  }
}
