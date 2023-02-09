class FCMResponseModel {
  FCMResponseModel({
    this.multicastId,
    this.success,
    this.failure,
    this.canonicalIds,
    this.results,
  });

  FCMResponseModel.fromJson(Map<String, dynamic> json) {
    multicastId = json["multicast_id"];
    success = json["success"];
    failure = json["failure"];
    canonicalIds = json["canonical_ids"];
    if (json["results"] != null) {
      results = <Results>[];
      for (final dynamic v in json["results"] as List<dynamic>) {
        results?.add(Results.fromJson(v));
      }
    }
  }

  int? multicastId;
  int? success;
  int? failure;
  int? canonicalIds;
  List<Results>? results;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["multicast_id"] = multicastId;
    map["success"] = success;
    map["failure"] = failure;
    map["canonical_ids"] = canonicalIds;
    if (results != null) {
      map["results"] = results?.map((Results v) => v.toJson()).toList();
    }
    return map;
  }
}

class Results {
  Results({
    this.messageId,
    this.error,
  });

  Results.fromJson(Map<String, dynamic> json) {
    messageId = json["message_id"];
    error = json["error"];
  }

  String? messageId;
  String? error;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["message_id"] = messageId;
    map["error"] = error;
    return map;
  }
}
