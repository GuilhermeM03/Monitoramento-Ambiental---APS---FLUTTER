# Mobile (Flutter)

Um app simples em Flutter que consome a API intermediária para exibir:
- Temperatura (°C)
- Umidade (%)
- Lista de poluentes (OpenAQ)

## Como rodar
1. Instale o Flutter SDK.
2. Abra a pasta `mobile_flutter` no VS Code/Android Studio.
3. Rode `flutter pub get`.
4. Suba o backend com Docker (veja README do backend).
5. Execute `flutter run` (emulador ou dispositivo).

### Apontando para o backend
- Por padrão o app usa `http://localhost:8000`.
- Em emulador Android, mude `baseUrl` em `main.dart` para `http://10.0.2.2:8000`.
- Você também pode definir via `--dart-define=API_BASE=http://10.0.2.2:8000` no comando `flutter run`.
