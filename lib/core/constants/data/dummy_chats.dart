// lib/features/chats/data/dummy_chats.dart
final List<Map<String, String>> kDummyChats = [
  {
    "avatar": "assets/images/avatars/avatar2.jpeg",
    "name": "김민수",
    "message": "내일 몇 시에 출발할까?",
    "time": "오전 9:12",
  },
  {
    "avatar": "assets/images/avatars/avatar1.jpeg",
    "name": "홍길동",
    "message": "어제 링크 보냈어! 확인해봐~",
    "time": "오전 10:03",
  },
  {
    "avatar": "assets/images/avatars/avatar1.jpeg",
    "name": "박연종",
    "message": "사진 정리해서 올려둘게",
    "time": "오전 11:47",
  },
  {
    "avatar": "assets/images/avatars/avatar2.jpeg",
    "name": "이준호",
    "message": "회의록 공유했음",
    "time": "오후 12:20",
  },
  {
    "avatar": "assets/images/avatars/avatar1.jpeg",
    "name": "최유진",
    "message": "위치 찍어줄게 잠깐만!",
    "time": "오후 1:02",
  },
  {
    "avatar": "assets/images/avatars/avatar2.jpeg",
    "name": "오하늘",
    "message": "그 파일 수정본으로 교체해줘",
    "time": "오후 2:18",
  },
  {
    "avatar": "assets/images/avatars/avatar1.jpeg",
    "name": "류태현",
    "message": "오프라인으로 보자",
    "time": "오후 3:40",
  },
  {
    "avatar": "assets/images/avatars/avatar2.jpeg",
    "name": "이고을",
    "message": "이번 주는 금요일이 낫다",
    "time": "오후 4:11",
  },
  {
    "avatar": "assets/images/avatars/avatar1.jpeg",
    "name": "이가은",
    "message": "확인했어 고마워!",
    "time": "오후 6:55",
  },
  {
    "avatar": "assets/images/avatars/avatar2.jpeg",
    "name": "박준수",
    "message": "초대 링크 다시 줄 수 있어?",
    "time": "오후 9:07",
  },
];

/// 사람별 채팅 내역 더미 데이터
/// - key: 채팅 상대 이름
/// - isMe: 내가 보낸 메시지면 true
final Map<String, List<Map<String, dynamic>>> kDummyChatMessages = {
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
