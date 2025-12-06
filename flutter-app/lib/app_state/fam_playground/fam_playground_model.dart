class FamPlaygroundModel {
  int currentPage = 0;
  final int totalPages = 3; // 90 numbers / 30 per page = 3 pages
  Set<int> selectedNumbers = {};

  void selectNumber(int number) {
    if (selectedNumbers.contains(number)) {
      selectedNumbers.remove(number);
    } else {
      selectedNumbers.add(number);
    }
  }

  bool isNumberSelected(int number) {
    return selectedNumbers.contains(number);
  }

  void nextPage() {
    if (currentPage < totalPages - 1) {
      currentPage++;
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      currentPage--;
    }
  }

  List<int> getNumbersForCurrentPage() {
    int start = currentPage * 30 + 1;
    int end = (currentPage + 1) * 30;
    if (end > 90) end = 90;
    return List.generate(end - start + 1, (index) => start + index);
  }
}
