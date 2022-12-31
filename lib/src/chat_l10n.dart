import 'package:flutter/material.dart';

/// Base chat l10n containing all required properties to provide localized copy.
/// Extend this class if you want to create a custom l10n.
@immutable
abstract class ChatL10n {
  /// Creates a new chat l10n based on provided copy.
  const ChatL10n({
    required this.attachmentButtonAccessibilityLabel,
    required this.emptyChatPlaceholder,
    required this.fileButtonAccessibilityLabel,
    required this.inputPlaceholder,
    required this.sendButtonAccessibilityLabel,
    required this.unreadMessagesLabel,
    required this.audioButtonAccessibilityLabel,
    required this.today,
    required this.yesterday,
    required this.playButtonAccessibilityLabel,
    required this.pauseButtonAccessibilityLabel,
    required this.audioTrackAccessibilityLabel,
    required this.videoButtonAccessibilityLabel,
    required this.videoPlayerAccessibilityLabel,
    required this.noCameraAvailableMessage,
    required this.cancelVideoRecordingButton,
    required this.videoRecordingSwitchCamera,
  });

  /// Accessibility label (hint) for the attachment button.
  final String attachmentButtonAccessibilityLabel;

  /// Placeholder when there are no messages.
  final String emptyChatPlaceholder;

  /// Accessibility label (hint) for the tap action on file message.
  final String fileButtonAccessibilityLabel;

  /// Accessibility label (hint) for the tap action on audio message when playing
  final String pauseButtonAccessibilityLabel;

  /// Accessibility label (hint) for the tap action on audio message when not playing
  final String playButtonAccessibilityLabel;

  /// Placeholder for the text field
  final String inputPlaceholder;

  /// Accessibility label (hint) for the send button.
  final String sendButtonAccessibilityLabel;

  /// Accessibility label (hint) for the audio button
  final String audioButtonAccessibilityLabel;

  /// Label for the unread messages header.
  final String unreadMessagesLabel;

  /// Today string
  final String today;

  /// Yesterday string
  final String yesterday;

  /// Accessibility label (hint) for the audio track
  final String audioTrackAccessibilityLabel;

  /// Accessibility label (hint) for the video player in video message
  final String videoPlayerAccessibilityLabel;

  /// Accessibility label (hint) for the video button
  final String videoButtonAccessibilityLabel;

  /// Message that appears in camera recorder when no camera is available
  final String noCameraAvailableMessage;

  /// Button to cancel recording of a video message
  final String cancelVideoRecordingButton;

  /// Tooltip/hint for the button to switch between cameras (front/back) in video recording UI
  final String videoRecordingSwitchCamera;
}

/// Arabic l10n which extends [ChatL10n].
@immutable
class ChatL10nAr extends ChatL10n {
  /// Creates Arabic l10n. Use this constructor if you want to
  /// override only a couple of properties, otherwise create a new class
  /// which extends [ChatL10n]
  const ChatL10nAr({
    super.attachmentButtonAccessibilityLabel = 'إرسال الوسائط',
    super.emptyChatPlaceholder = 'لا يوجد رسائل هنا بعد',
    super.fileButtonAccessibilityLabel = 'ملف',
    super.inputPlaceholder = 'الرسالة',
    super.sendButtonAccessibilityLabel = 'إرسال',
    super.unreadMessagesLabel = 'الرسائل غير المقروءة',
    super.today = 'Сьогодні',
    super.yesterday = 'Учора',
    super.audioButtonAccessibilityLabel = 'Записати звукове повідомлення',
    super.playButtonAccessibilityLabel = 'Відтворіть',
    super.pauseButtonAccessibilityLabel = 'Призупиніть',
    super.audioTrackAccessibilityLabel =
        'Натисніть, щоб відтворити / призупинити, проведіть пальцем, щоб шукати',
    super.videoButtonAccessibilityLabel = 'Записати відео-повідомлення',
    super.videoPlayerAccessibilityLabel = 'відтворити / призупинити',
    super.noCameraAvailableMessage = 'Немає доступної камери',
    super.cancelVideoRecordingButton = 'Скасувати',
    super.videoRecordingSwitchCamera = 'Переключити камеру',
  });
}

/// German l10n which extends [ChatL10n].
@immutable
class ChatL10nDe extends ChatL10n {
  /// Creates German l10n. Use this constructor if you want to
  /// override only a couple of variables, otherwise create a new class
  /// which extends [ChatL10n]
  const ChatL10nDe({
    super.attachmentButtonAccessibilityLabel = 'Medien senden',
    super.emptyChatPlaceholder = 'Noch keine Nachrichten',
    super.fileButtonAccessibilityLabel = 'Datei',
    super.inputPlaceholder = 'Nachricht',
    super.sendButtonAccessibilityLabel = 'Senden',
    super.unreadMessagesLabel = 'Ungelesene Nachrichten',
    super.today = 'Сьогодні',
    super.yesterday = 'Учора',
    super.audioButtonAccessibilityLabel = 'Записати звукове повідомлення',
    super.playButtonAccessibilityLabel = 'Відтворіть',
    super.pauseButtonAccessibilityLabel = 'Призупиніть',
    super.audioTrackAccessibilityLabel =
        'Натисніть, щоб відтворити / призупинити, проведіть пальцем, щоб шукати',
    super.videoButtonAccessibilityLabel = 'Записати відео-повідомлення',
    super.videoPlayerAccessibilityLabel = 'відтворити / призупинити',
    super.noCameraAvailableMessage = 'Немає доступної камери',
    super.cancelVideoRecordingButton = 'Скасувати',
    super.videoRecordingSwitchCamera = 'Переключити камеру',
  });
}

/// English l10n which extends [ChatL10n].
@immutable
class ChatL10nEn extends ChatL10n {
  /// Creates English l10n. Use this constructor if you want to
  /// override only a couple of properties, otherwise create a new class
  /// which extends [ChatL10n]
  const ChatL10nEn({
    super.attachmentButtonAccessibilityLabel = 'Send media',
    super.emptyChatPlaceholder = 'No messages here yet',
    super.fileButtonAccessibilityLabel = 'File',
    super.inputPlaceholder = 'Message',
    super.sendButtonAccessibilityLabel = 'Send',
    super.unreadMessagesLabel = 'Unread messages',
    super.today = 'Today',
    super.yesterday = 'Yesterday',
    super.audioButtonAccessibilityLabel = 'Record audio message',
    super.playButtonAccessibilityLabel = 'Play',
    super.pauseButtonAccessibilityLabel = 'Pause',
    super.audioTrackAccessibilityLabel = 'Tap to play/pause, slide to seek',
    super.videoButtonAccessibilityLabel = 'Record video message',
    super.videoPlayerAccessibilityLabel = 'Play/Pause',
    super.noCameraAvailableMessage = 'No camera available',
    super.cancelVideoRecordingButton = 'Cancel',
    super.videoRecordingSwitchCamera = 'Switch camera',
  });
}

/// Spanish l10n which extends [ChatL10n].
@immutable
class ChatL10nEs extends ChatL10n {
  /// Creates Spanish l10n. Use this constructor if you want to
  /// override only a couple of properties, otherwise create a new class
  /// which extends [ChatL10n]
  const ChatL10nEs({
    super.attachmentButtonAccessibilityLabel = 'Enviar multimedia',
    super.emptyChatPlaceholder = 'Aún no hay mensajes',
    super.fileButtonAccessibilityLabel = 'Archivo',
    super.inputPlaceholder = 'Mensaje',
    super.sendButtonAccessibilityLabel = 'Enviar',
    super.unreadMessagesLabel = 'Mensajes no leídos',
    super.today = 'Hoy',
    super.yesterday = 'Ayer',
    super.audioButtonAccessibilityLabel = 'Grabar mensaje de audio',
    super.playButtonAccessibilityLabel = 'Reproducir',
    super.pauseButtonAccessibilityLabel = 'Pausar',
    super.audioTrackAccessibilityLabel =
        'Toca para reproducir/pausar, desliza para buscar',
    super.videoButtonAccessibilityLabel = 'Grabar mensaje de video',
    super.videoPlayerAccessibilityLabel = 'Reproducir/Pausar',
    super.noCameraAvailableMessage = 'No hay cámara disponible',
    super.cancelVideoRecordingButton = 'Cancelar',
    super.videoRecordingSwitchCamera = 'Cambiar de cámara',
  });
}

/// Korean l10n which extends [ChatL10n].
@immutable
class ChatL10nKo extends ChatL10n {
  /// Creates Korean l10n. Use this constructor if you want to
  /// override only a couple of properties, otherwise create a new class
  /// which extends [ChatL10n]
  const ChatL10nKo({
    super.attachmentButtonAccessibilityLabel = '미디어 보내기',
    super.emptyChatPlaceholder = '주고받은 메시지가 없습니다',
    super.fileButtonAccessibilityLabel = '파일',
    super.inputPlaceholder = '메시지',
    super.sendButtonAccessibilityLabel = '보내기',
    super.unreadMessagesLabel = '읽지 않은 메시지',
    super.today = 'Сьогодні',
    super.yesterday = 'Учора',
    super.audioButtonAccessibilityLabel = 'Записати звукове повідомлення',
    super.playButtonAccessibilityLabel = 'Відтворіть',
    super.pauseButtonAccessibilityLabel = 'Призупиніть',
    super.audioTrackAccessibilityLabel =
        'Натисніть, щоб відтворити / призупинити, проведіть пальцем, щоб шукати',
    super.videoButtonAccessibilityLabel = 'Записати відео-повідомлення',
    super.videoPlayerAccessibilityLabel = 'відтворити / призупинити',
    super.noCameraAvailableMessage = 'Немає доступної камери',
    super.cancelVideoRecordingButton = 'Скасувати',
    super.videoRecordingSwitchCamera = 'Переключити камеру',
  });
}

/// Polish l10n which extends [ChatL10n].
@immutable
class ChatL10nPl extends ChatL10n {
  /// Creates Polish l10n. Use this constructor if you want to
  /// override only a couple of properties, otherwise create a new class
  /// which extends [ChatL10n]
  const ChatL10nPl({
    super.attachmentButtonAccessibilityLabel = 'Wyślij multimedia',
    super.emptyChatPlaceholder = 'Tu jeszcze nie ma wiadomości',
    super.fileButtonAccessibilityLabel = 'Plik',
    super.inputPlaceholder = 'Napisz wiadomość',
    super.sendButtonAccessibilityLabel = 'Wyślij',
    super.unreadMessagesLabel = 'Nieprzeczytane wiadomości',
    super.today = 'Dzisiaj',
    super.yesterday = 'Wczoraj',
    super.audioButtonAccessibilityLabel = 'Nagraj wiadomość dźwiękową',
    super.playButtonAccessibilityLabel = 'Odtwórz',
    super.pauseButtonAccessibilityLabel = 'Wstrzymać',
    super.audioTrackAccessibilityLabel =
        'Dotknij, aby odtworzyć/wstrzymać, przesuń, aby wyszukać',
    super.videoButtonAccessibilityLabel = 'Nagraj wiadomość wideo',
    super.videoPlayerAccessibilityLabel = 'Odtwórz/Wstrzymać',
    super.noCameraAvailableMessage = 'Brak dostępnej kamery',
    super.cancelVideoRecordingButton = 'Anuluj',
    super.videoRecordingSwitchCamera = 'Przełącz aparat',
  });
}

/// Portuguese l10n which extends [ChatL10n].
@immutable
class ChatL10nPt extends ChatL10n {
  /// Creates Portuguese l10n. Use this constructor if you want to
  /// override only a couple of properties, otherwise create a new class
  /// which extends [ChatL10n]
  const ChatL10nPt({
    super.attachmentButtonAccessibilityLabel = 'Envia mídia',
    super.emptyChatPlaceholder = 'Ainda não há mensagens aqui',
    super.fileButtonAccessibilityLabel = 'Arquivo',
    super.inputPlaceholder = 'Mensagem',
    super.sendButtonAccessibilityLabel = 'Enviar',
    super.unreadMessagesLabel = 'Mensagens não lidas',
    super.today = 'Сьогодні',
    super.yesterday = 'Учора',
    super.audioButtonAccessibilityLabel = 'Записати звукове повідомлення',
    super.playButtonAccessibilityLabel = 'Відтворіть',
    super.pauseButtonAccessibilityLabel = 'Призупиніть',
    super.audioTrackAccessibilityLabel =
        'Натисніть, щоб відтворити / призупинити, проведіть пальцем, щоб шукати',
    super.videoButtonAccessibilityLabel = 'Записати відео-повідомлення',
    super.videoPlayerAccessibilityLabel = 'відтворити / призупинити',
    super.noCameraAvailableMessage = 'Немає доступної камери',
    super.cancelVideoRecordingButton = 'Скасувати',
    super.videoRecordingSwitchCamera = 'Переключити камеру',
  });
}

/// Russian l10n which extends [ChatL10n].
@immutable
class ChatL10nRu extends ChatL10n {
  /// Creates Russian l10n. Use this constructor if you want to
  /// override only a couple of properties, otherwise create a new class
  /// which extends [ChatL10n]
  const ChatL10nRu({
    super.attachmentButtonAccessibilityLabel = 'Отправить медиа',
    super.emptyChatPlaceholder = 'Пока что у вас нет сообщений',
    super.fileButtonAccessibilityLabel = 'Файл',
    super.inputPlaceholder = 'Сообщение',
    super.sendButtonAccessibilityLabel = 'Отправить',
    super.unreadMessagesLabel = 'Непрочитанные сообщения',
    super.today = 'Сегодня',
    super.yesterday = 'Вчера',
    super.audioButtonAccessibilityLabel = 'Записать звуковое сообщение',
    super.playButtonAccessibilityLabel = 'Воспроизвести',
    super.pauseButtonAccessibilityLabel = 'Приостановить',
    super.audioTrackAccessibilityLabel =
        'Нажмите для воспроизведения / паузы, проведите пальцем для поиска',
    super.videoButtonAccessibilityLabel = 'Записать видео сообщение',
    super.videoPlayerAccessibilityLabel = 'Воспроизвести/Приостановить',
    super.noCameraAvailableMessage = 'Камера недоступна',
    super.cancelVideoRecordingButton = 'Отмена',
    super.videoRecordingSwitchCamera = 'Переключить камеру',
  });
}

/// Turkish l10n which extends [ChatL10n].
@immutable
class ChatL10nTr extends ChatL10n {
  /// Creates Turkish l10n. Use this constructor if you want to
  /// override only a couple of properties, otherwise create a new class
  /// which extends [ChatL10n]
  const ChatL10nTr({
    super.attachmentButtonAccessibilityLabel = 'Medya gönder',
    super.emptyChatPlaceholder = 'Henüz mesaj yok',
    super.fileButtonAccessibilityLabel = 'Dosya',
    super.inputPlaceholder = 'Mesaj yazın',
    super.sendButtonAccessibilityLabel = 'Gönder',
    super.unreadMessagesLabel = 'Okunmamış Mesajlar',
    super.today = 'Сегодня',
    super.yesterday = 'Вчера',
    super.audioButtonAccessibilityLabel = 'Записать звуковое сообщение',
    super.playButtonAccessibilityLabel = 'Воспроизвести',
    super.pauseButtonAccessibilityLabel = 'Приостановить',
    super.audioTrackAccessibilityLabel =
        'Нажмите для воспроизведения / паузы, проведите пальцем для поиска',
    super.videoButtonAccessibilityLabel = 'Записать видео сообщение',
    super.videoPlayerAccessibilityLabel = 'Воспроизвести/Приостановить',
    super.noCameraAvailableMessage = 'Камера недоступна',
    super.cancelVideoRecordingButton = 'Отмена',
    super.videoRecordingSwitchCamera = 'Переключить камеру',
  });
}

/// Ukrainian l10n which extends [ChatL10n].
@immutable
class ChatL10nUk extends ChatL10n {
  /// Creates Ukrainian l10n. Use this constructor if you want to
  /// override only a couple of properties, otherwise create a new class
  /// which extends [ChatL10n]
  const ChatL10nUk({
    super.attachmentButtonAccessibilityLabel = 'Надіслати медіа',
    super.emptyChatPlaceholder = 'Повідомлень ще немає',
    super.fileButtonAccessibilityLabel = 'Файл',
    super.inputPlaceholder = 'Повідомлення',
    super.sendButtonAccessibilityLabel = 'Надіслати',
    super.unreadMessagesLabel = 'Непрочитанi повідомлення',
    super.today = 'Сьогодні',
    super.yesterday = 'Учора',
    super.audioButtonAccessibilityLabel = 'Записати звукове повідомлення',
    super.playButtonAccessibilityLabel = 'Відтворіть',
    super.pauseButtonAccessibilityLabel = 'Призупиніть',
    super.audioTrackAccessibilityLabel =
        'Натисніть, щоб відтворити / призупинити, проведіть пальцем, щоб шукати',
    super.videoButtonAccessibilityLabel = 'Записати відео-повідомлення',
    super.videoPlayerAccessibilityLabel = 'відтворити / призупинити',
    super.noCameraAvailableMessage = 'Немає доступної камери',
    super.cancelVideoRecordingButton = 'Скасувати',
    super.videoRecordingSwitchCamera = 'Переключити камеру',
  });
}

/// Simplified Chinese l10n which extends [ChatL10n].
@immutable
class ChatL10nZhCN extends ChatL10n {
  /// Creates Simplified Chinese l10n. Use this constructor if you want to
  /// override only a couple of properties, otherwise create a new class
  /// which extends [ChatL10n]
  const ChatL10nZhCN({
    super.attachmentButtonAccessibilityLabel = '发送媒体文件',
    super.emptyChatPlaceholder = '暂无消息',
    super.fileButtonAccessibilityLabel = '文件',
    super.inputPlaceholder = '输入消息',
    super.sendButtonAccessibilityLabel = '发送',
    super.unreadMessagesLabel = '未读消息',
    super.today = 'Сьогодні',
    super.yesterday = 'Учора',
    super.audioButtonAccessibilityLabel = 'Записати звукове повідомлення',
    super.playButtonAccessibilityLabel = 'Відтворіть',
    super.pauseButtonAccessibilityLabel = 'Призупиніть',
    super.audioTrackAccessibilityLabel =
        'Натисніть, щоб відтворити / призупинити, проведіть пальцем, щоб шукати',
    super.videoButtonAccessibilityLabel = 'Записати відео-повідомлення',
    super.videoPlayerAccessibilityLabel = 'відтворити / призупинити',
    super.noCameraAvailableMessage = 'Немає доступної камери',
    super.cancelVideoRecordingButton = 'Скасувати',
    super.videoRecordingSwitchCamera = 'Переключити камеру',
  });
}

/// Traditional Chinese l10n which extends [ChatL10n].
@immutable
class ChatL10nZhTW extends ChatL10n {
  /// Creates Traditional Chinese l10n. Use this constructor if you want to
  /// override only a couple of properties, otherwise create a new class
  /// which extends [ChatL10n]
  const ChatL10nZhTW({
    super.attachmentButtonAccessibilityLabel = '傳送媒體',
    super.emptyChatPlaceholder = '還沒有訊息在這裡',
    super.fileButtonAccessibilityLabel = '檔案',
    super.inputPlaceholder = '輸入訊息',
    super.sendButtonAccessibilityLabel = '傳送',
    super.unreadMessagesLabel = '未讀訊息',
    super.today = 'Сьогодні',
    super.yesterday = 'Учора',
    super.audioButtonAccessibilityLabel = 'Записати звукове повідомлення',
    super.playButtonAccessibilityLabel = 'Відтворіть',
    super.pauseButtonAccessibilityLabel = 'Призупиніть',
    super.audioTrackAccessibilityLabel =
        'Натисніть, щоб відтворити / призупинити, проведіть пальцем, щоб шукати',
    super.videoButtonAccessibilityLabel = 'Записати відео-повідомлення',
    super.videoPlayerAccessibilityLabel = 'відтворити / призупинити',
    super.noCameraAvailableMessage = 'Немає доступної камери',
    super.cancelVideoRecordingButton = 'Скасувати',
    super.videoRecordingSwitchCamera = 'Переключити камеру',
  });
}
