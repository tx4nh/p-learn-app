## Cài đặt và khởi chạy
```
1. git clone <repository-url>
2. cd <project-folder>
3. flutter pub get
4. flutter run
*: Cần có Flutter SDK, Android Studio(androind) / Xcode(IOS), Emulator
```

## Cấu trúc tổng quát
```
lib/
├── main.dart
├── api/
│   ├── api_student.dart
│   ├── endpoints.dart
│   ├── interceptors.dart
│   └── exceptions.dart
├── config/
│   ├── app_config.dart
│   └── routes.dart
├── models/
│   ├── user.dart
│   ├── course.dart
│   ├── assignment.dart
│   ├── study_group.dart
│   ├── grade.dart
│   ├── api_response.dart
│   └── notification.dart
├── providers/
│   ├── auth_provider.dart
│   ├── course_provider.dart
│   ├── assignment_provider.dart
│   ├── gpa_provider.dart
│   ├── notification_provider.dart
│   └── theme_provider.dart
├── repositories/
│   ├── user_repository.dart
│   ├── course_repository.dart
│   ├── assignment_repository.dart
│   ├── study_group_repository.dart
│   └── base_repository.dart
├── services/
│   ├── storage_service.dart
│   ├── notification_service.dart
│   ├── auth_service.dart
│   └── database_service.dart
├── screens/
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── main_navigation/
│   │   ├── main_tab_screen.dart
│   │   └── tab_navigator.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── dashboard_screen.dart
│   ├── courses/
│   │   ├── course_list_screen.dart
│   │   ├── course_detail_screen.dart
│   │   ├── add_course_screen.dart
│   │   └── edit_course_screen.dart
│   ├── assignments/
│   │   ├── assignment_list_screen.dart
│   │   ├── assignment_detail_screen.dart
│   │   ├── add_assignment_screen.dart
│   │   └── assignment_calendar_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   └── settings_screen.dart
│   ├── tools/
│   │   ├── tools_screen.dart
│   │   ├── gpa_calculator_screen.dart
│   │   ├── pomodoro_screen.dart
│   │   ├── study_planner_screen.dart
│   │   └── ai_chat_screen.dart
│   └── community/
│       ├── study_groups_screen.dart
│       ├── group_detail_screen.dart
│       ├── create_group_screen.dart
│       └── join_group_screen.dart
├── widgets/
│   ├── course_card.dart
│   ├── assignment_tile.dart
│   ├── pomodoro_timer.dart
│   ├── grade_chart.dart
│   ├── study_group_card.dart
│   ├── notification_item.dart
│   ├── loading_widget.dart
│   ├── empty_state_widget.dart
│   ├── common/
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── custom_app_bar.dart
│   │   ├── custom_dialog.dart
│   │   ├── custom_bottom_sheet.dart
│   │   └── custom_loading.dart
│   └── charts/
│       ├── gpa_chart.dart
│       ├── progress_chart.dart
│       └── performance_chart.dart
└── utils/
    ├── theme.dart
    ├── constants.dart
    ├── helpers.dart
    ├── validators.dart
    ├── date_utils.dart
    ├── extensions.dart
    └── app_logger.dart
```

## Giải thích các thư mục chính:
```
- **api/**: Xử lý tất cả API calls và kết nối backend
- **config/**: Cấu hình app, routes, environment
- **models/**: Data models cho app
- **providers/**: State management với Provider pattern
- **repositories/**: Abstraction layer giữa data source và business logic
- **services/**: Các service như storage, notification, auth
- **screens/main_navigation/**: Chứa tab navigation và routing logic
- **widgets/charts/**: Các widget chart cho hiển thị thống kê
- **core/**: Core functionality như error handling, database
- **utils/extensions.dart**: Extension methods cho các class

Kết nối BE sẽ chủ yếu ở **api/** folder và được call thông qua **repositories/**.
```