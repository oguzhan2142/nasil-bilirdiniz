class Utils {



  static List removeNulls(List list) {
    for (var item in list) {
      if (item == null) list.remove(item);
    }
    return list;
  }
}
