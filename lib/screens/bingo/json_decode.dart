class JsonDecode {

  static String jsonDecodeTitle(Map<String, dynamic> data) {
    return data['title'];
  }

  static String jsonDecodeDescription(Map<String, dynamic> data) {
    return data['description'];
  }

  static int jsonDecodeChallengeId(Map<String, dynamic> data) {
    return data['id'];
  }

  static String jsonDecodeType(Map<String, dynamic> data) {
    return data['type'];
  }

  static String jsonDecodeDifficulty(Map<String, dynamic> data) {
    return data['difficulty'];
  }

  static int jsonDecodeRewardPoints(Map<String, dynamic> data) {
    return data['rewardPoints'];
  }

  static bool jsonDecodeActive(Map<String, dynamic> data) {
    return data['active'];
  }

  static String jsonDecodeStatus(Map<String, dynamic> data) {
    return data['status'];
  }

  static String jsonDecodeCategory(Map<String, dynamic> data) {
    return data['category'];
  }

}