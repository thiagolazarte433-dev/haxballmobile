# HaxBall Ultra Mobile 🟣⚽

Cliente móvil premium (Android, preparado para iOS) para **haxball.com/play**,
con WebView optimizado, joystick virtual, botón de Kick, avatar personalizado
y tema oscuro violeta neón.

---

## 1. Estructura del proyecto

```
haxball_ultra_mobile/
├── pubspec.yaml
├── android/
│   └── app/src/main/AndroidManifest.xml
├── assets/
│   ├── icon/app_icon.png            ← icono 1024x1024 (agrégalo tú)
│   └── splash/splash_logo.png       ← logo splash (agrégalo tú)
└── lib/
    ├── main.dart
    ├── theme/
    │   └── app_theme.dart           # Colores/gradientes violeta-neón
    ├── models/
    │   └── favorite_room.dart
    ├── providers/
    │   ├── settings_provider.dart   # FPS, opacidad, tamaño de controles...
    │   ├── favorites_provider.dart  # Salas favoritas (persistidas)
    │   └── avatar_provider.dart     # Avatar base64 persistido
    ├── screens/
    │   ├── splash_screen.dart
    │   ├── home_screen.dart
    │   ├── webview_screen.dart      # ⭐ Pantalla principal del juego
    │   ├── favorites_screen.dart
    │   ├── avatar_picker_screen.dart
    │   └── settings_screen.dart
    ├── widgets/
    │   ├── app_drawer.dart
    │   ├── virtual_joystick.dart
    │   ├── kick_button.dart
    │   └── ping_indicator.dart
    └── utils/
        └── js_injector.dart         # Todo el JS inyectado en la WebView
```

---

## 2. Instalación

```bash
flutter create --org com.tuempresa haxball_ultra_mobile_tmp   # solo para copiar android/ios base si hace falta
flutter pub get
```

Copia los archivos generados en este proyecto sobre la carpeta creada por
`flutter create`, o simplemente usa este árbol de carpetas ya listo y ejecuta:

```bash
cd haxball_ultra_mobile
flutter pub get
```

---

## 3. Icono de la app

1. Coloca tu icono cuadrado (1024×1024 px, PNG con fondo) en:
   `assets/icon/app_icon.png`
2. (Opcional, para adaptive icon Android) coloca la versión solo-foreground
   (sin fondo, con márgenes) en `assets/icon/app_icon_foreground.png`.
3. Genera los iconos nativos:

```bash
flutter pub run flutter_launcher_icons
```

---

## 4. Splash screen nativo

1. Coloca tu logo en `assets/splash/splash_logo.png` (fondo transparente).
2. Genera el splash nativo:

```bash
flutter pub run flutter_native_splash:create
```

---

## 5. Compilar el APK

```bash
# APK de release (un solo archivo, más pesado)
flutter build apk --release

# Recomendado: App Bundle para Play Store
flutter build appbundle --release

# APKs divididos por arquitectura (más livianos)
flutter build apk --split-per-abi --release
```

El APK final queda en:
`build/app/outputs/flutter-apk/app-release.apk`

### Preparado para iOS

```bash
flutter build ios --release
```

(Requiere macOS + Xcode + cuenta de desarrollador Apple para firmar y
distribuir. `webview_flutter_wkwebview` ya está incluido en `pubspec.yaml`.)

---

## 6. Notas técnicas importantes

- **Sesión persistente**: `webview_flutter` con `webview_flutter_android`
  usa el almacenamiento nativo de cookies/localStorage de Android WebView,
  por lo que la sesión de HaxBall se mantiene al minimizar o cerrar la app
  (no se llama a `clearCookies()` en ningún punto del código).
- **Controles → teclado simulado**: HaxBall se controla internamente con
  eventos de teclado reales (flechas + tecla X). El joystick y el botón
  Kick funcionan disparando `KeyboardEvent('keydown'/'keyup', ...)` sobre
  `document` desde JavaScript inyectado (`utils/js_injector.dart`). Esto es
  la forma más fiable de controlar el motor Canvas/WebGL del juego desde
  fuera, ya que no expone una API DOM directa.
- **Detección de "estar en una sala"**: se vigila cada 700ms si existe un
  `<canvas>` visible en la página (`roomDetectorWatcher`). Al detectarlo,
  la app entra en landscape + fullscreen inmersivo y muestra los controles;
  al salir, se restauran las barras del sistema.
- **Avatar con foto**: el cliente web oficial de HaxBall solo admite un
  emoji/texto corto como avatar, no imágenes arbitrarias. El código deja
  preparado el flujo completo (selección → base64 → inyección) y un
  "gancho" (`window.HB_setAvatar`) que funcionará automáticamente en salas
  o headless-hosts con scripts que sí soporten avatares por imagen. Si tu
  comunidad usa un host con un sistema propio de avatares, solo hace falta
  exponer esa función `HB_setAvatar(base64)` en su script para que la app
  la use tal cual.
- **Gamepad Bluetooth**: los mandos Bluetooth ya son reconocidos por
  Android como eventos de teclado/joystick del sistema operativo, así que
  en muchos casos funcionarán automáticamente dentro de la WebView sin
  código adicional. El interruptor en Ajustes está pensado para, en una
  futura iteración, mapear explícitamente el `RawKeyboard`/`Gamepad API` de
  Flutter a los mismos `dispatchKey` que usa el joystick virtual.

---

## 7. Permisos utilizados

| Permiso | Uso |
|---|---|
| `INTERNET` | Cargar HaxBall |
| `CAMERA` | Tomar foto para avatar |
| `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE` | Elegir foto de galería |
| `WAKE_LOCK` | Evitar que la pantalla se apague durante la partida |
| `POST_NOTIFICATIONS` | Notificaciones push opcionales |

---

## 8. Próximos pasos sugeridos

- Firmar el APK/AAB con tu propio keystore (`key.properties` +
  configuración en `android/app/build.gradle`) antes de publicar.
- Integrar un backend propio de notificaciones push (Firebase Cloud
  Messaging) si activas la opción de notificaciones.
- Añadir soporte explícito de `Gamepad API`/`RawKeyboard` de Flutter para
  mapear botones de mando físico 1:1 con las teclas de HaxBall.
