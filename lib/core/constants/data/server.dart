// lib/core/constants/data/server.dart

// A stub class to simulate a server providing data for the chat application.
// This is used for development and testing purposes before connecting to a real backend.
class Server {

  final Map<String, List<Map<String, dynamic>>> _kDummyChatMessages = {
    "김민수": [
      {
        "isMe": true,
        "message": "내일 차 가져갈까, 아니면 지하철 탈까?",
        "time": "오전 9:05",
      },
      {
        "isMe": false,
        "message": "지하철 타는 게 나을 듯 ㅋㅋ",
        "time": "오전 9:10",
      },
      {
        "isMe": false,
        "message": "내일 몇 시에 출발할까?",
        "time": "오전 9:12",
      },
    ],
    "홍길동": [
      {
        "isMe": true,
        "message": "어제 말한 자료 정리해놨어?",
        "time": "오전 9:45",
      },
      {
        "isMe": false,
        "message": "웬만한 건 정리했어. 어제 링크 보냈어! 확인해봐~",
        "time": "오전 10:03",
      },
    ],
    "박연종": [
      {
        "isMe": false,
        "message": "그때 찍은 사진들 꽤 많더라 ㅎㅎ",
        "time": "오전 11:30",
      },
      {
        "isMe": true,
        "message": "응 천천히 올려줘도 돼!",
        "time": "오전 11:40",
      },
      {
        "isMe": false,
        "message": "사진 정리해서 올려둘게",
        "time": "오전 11:47",
      },
    ],
    "이준호": [
      {
        "isMe": true,
        "message": "어제 회의 정리해둔 거 있어?",
        "time": "오전 11:58",
      },
      {
        "isMe": false,
        "message": "간단히 메모해놔서 지금 정리 중이야.",
        "time": "오후 12:10",
      },
      {
        "isMe": false,
        "message": "회의록 공유했음",
        "time": "오후 12:20",
      },
    ],
    "최유진": [
      {
        "isMe": true,
        "message": "도착하면 톡 한 번만 줘!",
        "time": "오후 12:50",
      },
      {
        "isMe": false,
        "message": "ㅇㅋ 나 이제 출발해.",
        "time": "오후 12:57",
      },
      {
        "isMe": false,
        "message": "위치 찍어줄게 잠깐만!",
        "time": "오후 1:02",
      },
    ],
    "오하늘": [
      {
        "isMe": true,
        "message": "어제 버전 말고 최신 파일이 뭐였지?",
        "time": "오후 2:05",
      },
      {
        "isMe": false,
        "message": "폴더에 v3라고 되어있는 거!",
        "time": "오후 2:14",
      },
      {
        "isMe": false,
        "message": "그 파일 수정본으로 교체해줘",
        "time": "오후 2:18",
      },
    ],
    "류태현": [
      {
        "isMe": true,
        "message": "이번 주에 한 번 모여서 정리하자.",
        "time": "오후 3:20",
      },
      {
        "isMe": false,
        "message": "좋아, 온라인 말고 직접 보는 게 좋겠다.",
        "time": "오후 3:35",
      },
      {
        "isMe": true,
        "message": "오프라인으로 보자",
        "time": "오후 3:40",
      },
    ],
    "이고을": [
      {
        "isMe": false,
        "message": "다음 주 스케줄 어떻게 돼?",
        "time": "오후 4:02",
      },
      {
        "isMe": true,
        "message": "수요일이나 금요일 둘 다 가능!",
        "time": "오후 4:08",
      },
      {
        "isMe": false,
        "message": "이번 주는 금요일이 낫다",
        "time": "오후 4:11",
      },
    ],
    "이가은": [
      {
        "isMe": true,
        "message": "요청한 내용 반영해서 다시 올려뒀어.",
        "time": "오후 6:40",
      },
      {
        "isMe": false,
        "message": "오 확인해볼게.",
        "time": "오후 6:50",
      },
      {
        "isMe": false,
        "message": "확인했어 고마워!",
        "time": "오후 6:55",
      },
    ],
    "박준수": [
      {
        "isMe": true,
        "message": "어제 방 만든 링크 혹시 날려버렸어?",
        "time": "오후 8:55",
      },
      {
        "isMe": false,
        "message": "나도 찾는 중 ㅋㅋ",
        "time": "오후 9:02",
      },
      {
        "isMe": false,
        "message": "초대 링크 다시 줄 수 있어?",
        "time": "오후 9:07",
      },
    ],
  };

  // 모든 사용자 목록 더미 데이터
  static const List<Map<String, dynamic>> _kDummyUsers = [
    {
      "id": "user_001",
      "name": "나", // 현재 사용자
      "avatar": "assets/images/avatars/avatar1.jpeg",
      "statusMessage": "오늘도 화이팅!",
      "isMe": true,
    },
    {
      "id": "user_002",
      "name": "김민수",
      "avatar": "assets/images/avatars/avatar2.jpeg",
      "statusMessage": "내일 미팅 준비 완료",
      "isMe": false,
    },
    {
      "id": "user_003",
      "name": "홍길동",
      "avatar": "assets/images/avatars/avatar1.jpeg",
      "statusMessage": "어제 보낸 자료 확인해봐!",
      "isMe": false,
    },
    {
      "id": "user_004",
      "name": "박연종",
      "avatar": "assets/images/avatars/avatar1.jpeg",
      "statusMessage": "여행 가고 싶다 ✈️",
      "isMe": false,
    },
    {
      "id": "user_005",
      "name": "이준호",
      "avatar": "assets/images/avatars/avatar2.jpeg",
      "statusMessage": "코딩 중...",
      "isMe": false,
    },
    {
      "id": "user_006",
      "name": "최유진",
      "avatar": "assets/images/avatars/avatar1.jpeg",
      "statusMessage": "커피 한 잔의 여유 ☕",
      "isMe": false,
    },
    {
      "id": "user_007",
      "name": "오하늘",
      "avatar": "assets/images/avatars/avatar2.jpeg",
      "statusMessage": "새로운 아이디어 구상 중",
      "isMe": false,
    },
    {
      "id": "user_008",
      "name": "류태현",
      "avatar": "assets/images/avatars/avatar1.jpeg",
      "statusMessage": "운동 시작!",
      "isMe": false,
    },
    {
      "id": "user_009",
      "name": "이고을",
      "avatar": "assets/images/avatars/avatar2.jpeg",
      "statusMessage": "영화 볼 사람?",
      "isMe": false,
    },
    {
      "id": "user_010",
      "name": "이가은",
      "avatar": "assets/images/avatars/avatar1.jpeg",
      "statusMessage": "책 읽는 중",
      "isMe": false,
    },
    {
      "id": "user_011",
      "name": "박준수",
      "avatar": "assets/images/avatars/avatar2.jpeg",
      "statusMessage": "게임 한 판?",
      "isMe": false,
    },
    {
      "id": "user_012",
      "name": "강경민",
      "avatar": "assets/images/avatars/avatar1.jpeg",
      "statusMessage": "새로운 시작, 새로운 하루!",
      "isMe": false,
    },
    {
      "id": "user_013",
      "name": "강다원",
      "avatar": "assets/images/avatars/avatar2.jpeg",
      "statusMessage": "코딩 중... 잠시만요!",
      "isMe": false,
    },
    {
      "id": "user_014",
      "name": "강동규",
      "avatar": "assets/images/avatars/avatar1.jpeg",
      "statusMessage": "음악은 나의 삶",
      "isMe": false,
    },
    {
      "id": "user_015",
      "name": "강동훈",
      "avatar": "assets/images/avatars/avatar2.jpeg",
      "statusMessage": "휴가 중 🌴",
      "isMe": false,
    },
    {
      "id": "user_016",
      "name": "강병준",
      "avatar": "assets/images/avatars/avatar1.jpeg",
      "statusMessage": "생각하는 중...",
      "isMe": false,
    },
    {
      "id": "user_017",
      "name": "강성근",
      "avatar": "assets/images/avatars/avatar2.jpeg",
      "statusMessage": "플러터는 최고야!",
      "isMe": false,
    },
    {
      "id": "user_018",
      "name": "강유진",
      "avatar": "assets/images/avatars/avatar1.jpeg",
      "statusMessage": "운동 중",
      "isMe": false,
    },
    {
      "id": "user_019",
      "name": "강호성",
      "avatar": "assets/images/avatars/avatar1.jpeg",
      "statusMessage": "카톡하는 중입니다.",
      "isMe": false,
    },
    {
      "id": "user_020",
      "name": "강민수",
      "avatar": "assets/images/avatars/avatar2.jpeg",
      "statusMessage": "연락주세요!",
      "isMe": false,
    },
  ];

  Map<String, dynamic> getCurrentUser() {
    return _kDummyUsers.firstWhere((user) => user['isMe'] == true);
  }

  List<Map<String, dynamic>> getFriends() {
    return _kDummyUsers.where((user) => user['isMe'] == false).toList();
  }

  List<Map<String, dynamic>> getChatRoomList() {

    final chatRooms = [
      {
        "id": 101,
        "avatarUrl": "assets/images/avatars/avatar2.jpeg",
        "name": "김민수",
        "lastMessage": "내일 몇 시에 출발할까?",
        "lastMessageTime": "오전 9:12",
        "isGroupChat": false,
      },
      {
        "id": 102,
        "avatarUrl": "assets/images/avatars/avatar1.jpeg",
        "name": "홍길동",
        "lastMessage": "어제 링크 보냈어! 확인해봐~",
        "lastMessageTime": "오전 10:03",
        "isGroupChat": false,
      },
      {
        "id": 103,
        "avatarUrl": "assets/images/avatars/avatar1.jpeg",
        "name": "박연종",
        "lastMessage": "사진 정리해서 올려둘게",
        "lastMessageTime": "오전 11:47",
        "isGroupChat": false,
      },
      {
        "id": 104,
        "avatarUrl": "assets/images/avatars/avatar2.jpeg",
        "name": "이준호",
        "lastMessage": "회의록 공유했음",
        "lastMessageTime": "오후 12:20",
        "isGroupChat": false,
      },
      {
        "id": 105,
        "avatarUrl": "assets/images/avatars/avatar1.jpeg",
        "name": "최유진",
        "lastMessage": "위치 찍어줄게 잠깐만!",
        "lastMessageTime": "오후 1:02",
        "isGroupChat": false,
      },
      {
        "id": 106,
        "avatarUrl": "assets/images/avatars/avatar2.jpeg",
        "name": "오하늘",
        "lastMessage": "그 파일 수정본으로 교체해줘",
        "lastMessageTime": "오후 2:18",
        "isGroupChat": false,
      },
      {
        "id": 107,
        "avatarUrl": "assets/images/avatars/avatar1.jpeg",
        "name": "류태현",
        "lastMessage": "오프라인으로 보자",
        "lastMessageTime": "오후 3:40",
        "isGroupChat": false,
      },
      {
        "id": 108,
        "avatarUrl": "assets/images/avatars/avatar2.jpeg",
        "name": "이고을",
        "lastMessage": "이번 주는 금요일이 낫다",
        "lastMessageTime": "오후 4:11",
        "isGroupChat": false,
      },
      {
        "id": 109,
        "avatarUrl": "assets/images/avatars/avatar1.jpeg",
        "name": "이가은",
        "lastMessage": "확인했어 고마워!",
        "lastMessageTime": "오후 6:55",
        "isGroupChat": false,
      },
      {
        "id": 110,
        "avatarUrl": "assets/images/avatars/avatar2.jpeg",
        "name": "박준수",
        "lastMessage": "초대 링크 다시 줄 수 있어?",
        "lastMessageTime": "오후 9:07",
        "isGroupChat": false,
      },
    ];

    for (var room in chatRooms) {
      final chatName = room['name'] as String;
      final unreadCount = _kDummyChatMessages[chatName]
              ?.where((m) => m['isMe'] == false)
              .length ??
          0;
      room['unreadCount'] = unreadCount;
    }

    return chatRooms;
  }

  List<Map<String, dynamic>> getMessages(String chatName) {
    return _kDummyChatMessages[chatName] ?? [];
  }

  static const _kDummyFriendsForNewChat = [
    {"name": "강경민", "avatar": "assets/images/avatars/avatar1.jpeg", "statusMessage": "새로운 시작, 새로운 하루!"},
    {"name": "강다원", "avatar": "assets/images/avatars/avatar2.jpeg", "statusMessage": "코딩 중... 잠시만요!"},
    {"name": "강동규", "avatar": "assets/images/avatars/avatar1.jpeg", "statusMessage": "음악은 나의 삶"},
    {"name": "강동훈", "avatar": "assets/images/avatars/avatar2.jpeg", "statusMessage": "휴가 중 🌴"},
    {"name": "강병준", "avatar": "assets/images/avatars/avatar1.jpeg", "statusMessage": "생각하는 중..."},
    {"name": "강성근", "avatar": "assets/images/avatars/avatar2.jpeg", "statusMessage": "플러터는 최고야!"},
    {"name": "강유진", "avatar": "assets/images/avatars/avatar1.jpeg", "statusMessage": "운동 중"},
    {"name": "강호성", "avatar": "assets/images/avatars/avatar1.jpeg", "statusMessage": "카톡하는 중입니다."},
    {"name": "강민수", "avatar": "assets/images/avatars/avatar2.jpeg", "statusMessage": "연락주세요!"},
  ];

  List<Map<String, String>> getFriendsForNewChat() {
    return _kDummyFriendsForNewChat;
  }
}

