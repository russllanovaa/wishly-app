# 🎁 Wishly — застосунок для списків бажань

Мобільний застосунок на **Flutter**, у якому можна створювати власні списки бажань (вішлісти) та додавати до них подарунки з фото, ціною й посиланням на магазин. Дані зберігаються в хмарі **Firebase**.

## Можливості

- **Реєстрація та вхід** через email і пароль (Firebase Authentication)
- **Вішлісти** — створення, редагування, видалення; сортування за назвою або датою
- **Бажання у списку** — назва, ціна, посилання, короткий опис, категорія, фото
- **Фото подарунка** — вибір зображення на пристрої та завантаження у Firebase Storage
- **Сортування та фільтрація** бажань за ціною, назвою та категорією
- **Бронювання подарунка** — позначка «заброньовано» та скасування бронювання
- **Публічні бажання** — позначка, чи бачать бажання інші
- **Відкриття посилання** на товар прямо із застосунку
- **Аналітика та звіти про збої** — Firebase Analytics і Crashlytics

## Технології

- **Flutter / Dart** (SDK ^3.9)
- **BLoC** (`flutter_bloc`) — керування станом
- **Firebase:** Authentication, Cloud Firestore, Storage, Analytics, Crashlytics
- `image_picker`, `url_launcher`, `equatable`, `uuid`
- Тести: `flutter_test`, `mockito`

## Архітектура

```
lib/
├── main.dart                 # ініціалізація Firebase, Crashlytics, Analytics
├── core/widgets/             # спільні віджети (кнопки, поля, хвилястий хедер)
├── models/                   # Wishlist, WishItem
├── repository/               # робота з Firestore та Storage
└── screens/
    ├── auth/                 # вхід, реєстрація, AuthGate
    ├── home/                 # головний екран зі списком вішлістів
    ├── misc/                 # splash та loading
    └── wishlist/             # деталі вішліста, додавання/редагування + BLoC
```

Застосунок побудований за шаблоном **Repository + BLoC**: екрани надсилають події в BLoC, BLoC звертається до репозиторіїв, а репозиторії — до Firebase.

## Запуск

**Потрібно:** Flutter SDK 3.x, Android Studio або VS Code, емулятор чи телефон.

```bash
git clone https://github.com/russllanovaa/wishly-app.git
cd wishly-app
flutter pub get
flutter run
```

Конфігурацію Firebase вже підключено (`lib/firebase_options.dart`, `android/app/google-services.json`).
