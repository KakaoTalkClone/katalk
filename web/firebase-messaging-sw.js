// Firebase 라이브러리 임포트 (버전은 호환성을 위해 Compat 버전 사용)
importScripts(
  "https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js"
);

// [중요] main.dart에 넣었던 설정값과 동일해야 합니다.
const firebaseConfig = {
  apiKey: "AIzaSyCydG1oH2gWlC7zp1RgLjZUgiDaPC0uXME",
  authDomain: "piuda-bfb0f.firebaseapp.com",
  projectId: "piuda-bfb0f",
  storageBucket: "piuda-bfb0f.appspot.com",
  messagingSenderId: "137988483909",
  appId: "1:137988483909:web:34203cf1e3109d4188ec2c",
};

// Firebase 초기화
firebase.initializeApp(firebaseConfig);

// 메시징 객체 가져오기
const messaging = firebase.messaging();

// 백그라운드 메시지 수신 핸들러
messaging.onBackgroundMessage(function (payload) {
  console.log("[firebase-messaging-sw.js] 백그라운드 메시지 수신:", payload);

  // 알림 타이틀과 내용 추출
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png", // web/icons 폴더 내 아이콘 경로 (기본 Flutter 아이콘)
    data: payload.data, // 클릭 시 데이터 전달을 위해 포함
  };

  return self.registration.showNotification(
    notificationTitle,
    notificationOptions
  );
});

// 알림 클릭 이벤트 리스너
self.addEventListener("notificationclick", function (event) {
  console.log("[firebase-messaging-sw.js] 알림 클릭됨");
  event.notification.close();

  // 앱을 열거나, 이미 열려있는 창에 포커스를 줍니다.
  event.waitUntil(
    clients
      .matchAll({ type: "window", includeUncontrolled: true })
      .then(function (windowClients) {
        for (let i = 0; i < windowClients.length; i++) {
          const client = windowClients[i];
          // 메인 URL이 포함된 탭을 찾으면 포커스
          if (
            client.url.includes("localhost") ||
            client.url.includes("127.0.0.1")
          ) {
            return client.focus();
          }
        }
        if (clients.openWindow) {
          return clients.openWindow("/");
        }
      })
  );
});
