/// Colección de snippets de JavaScript inyectados en la WebView de HaxBall.
///
/// IMPORTANTE / LIMITACIÓN CONOCIDA:
/// El cliente oficial de HaxBall (haxball.com/play) controla el movimiento
/// y el disparo mediante eventos reales de teclado (flechas + tecla "X" por
/// defecto) capturados por el motor del juego (WebGL/Canvas), no mediante
/// elementos del DOM accesibles. Por eso la estrategia más fiable desde un
/// WebView es **simular eventos de teclado nativos** (keydown/keyup) sobre
/// `document`, que es exactamente lo que hacen estos scripts. Esto funciona
/// para el movimiento y el disparo dentro de una sala normal.
///
/// El "avatar con foto" es una función que solo funciona si la sala/host
/// tiene un script (headless host) que soporte avatares por imagen (por
/// ejemplo mediante el campo de chat o una extensión de la room API). En el
/// cliente web estándar de HaxBall el avatar es un emoji/texto corto, no una
/// imagen arbitraria. El código de este proyecto deja preparado el "gancho"
/// (inyección de base64 + intento de comando de chat) para que funcione en
/// salas/scripts que sí lo soporten, y cae de forma segura si no.
class JsInjector {
  JsInjector._();

  /// Se ejecuta al terminar de cargar cada página: evita zoom, gestos de
  /// scroll no deseados y ajusta el viewport para uso móvil a pantalla
  /// completa.
  static const String mobileOptimizations = '''
    (function() {
      try {
        // Fuerza un viewport fijo, sin zoom por pellizco ni doble-tap.
        var meta = document.querySelector('meta[name="viewport"]');
        if (!meta) {
          meta = document.createElement('meta');
          meta.name = 'viewport';
          document.head.appendChild(meta);
        }
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover';

        // Bloquea el scroll elástico / rebote y el long-press que abre menús.
        var style = document.createElement('style');
        style.innerHTML = `
          html, body {
            overflow: hidden !important;
            overscroll-behavior: none !important;
            touch-action: none !important;
            -webkit-user-select: none !important;
            user-select: none !important;
            -webkit-touch-callout: none !important;
            background: #000 !important;
          }
        `;
        document.head.appendChild(style);

        document.addEventListener('gesturestart', function (e) { e.preventDefault(); });
        document.addEventListener('dblclick', function (e) { e.preventDefault(); }, { passive: false });

        window.__hbUltraReady = true;
      } catch (e) { console.log('hbUltra optimizations error', e); }
    })();
  ''';

  /// Vigila el DOM para detectar si el usuario está dentro de una sala
  /// jugando (existe el canvas del juego) o si sigue en el lobby/menú.
  /// Notifica a Flutter vía el JavaScriptChannel `RoomState`.
  static const String roomDetectorWatcher = '''
    (function() {
      if (window.__hbUltraWatcherStarted) return;
      window.__hbUltraWatcherStarted = true;
      var lastState = null;
      setInterval(function() {
        try {
          var canvas = document.querySelector('canvas');
          var inRoom = !!(canvas && canvas.width > 0 && canvas.height > 0 && document.querySelector('canvas').style.display !== 'none');
          var state = inRoom ? 'IN_ROOM' : 'IN_MENU';
          if (state !== lastState) {
            lastState = state;
            if (window.RoomState) RoomState.postMessage(state);
          }
        } catch (e) {}
      }, 700);
    })();
  ''';

  /// Genera el JS que simula pulsar/soltar una tecla física por su
  /// `keyCode`/`code`. Usado por el joystick virtual y el botón de kick.
  static String dispatchKey({required String code, required int keyCode, required bool keyDown}) {
    final type = keyDown ? 'keydown' : 'keyup';
    return '''
      (function() {
        try {
          var evt = new KeyboardEvent('$type', {
            code: '$code',
            key: '$code',
            keyCode: $keyCode,
            which: $keyCode,
            bubbles: true,
            cancelable: true
          });
          document.dispatchEvent(evt);
          if (document.activeElement) document.activeElement.dispatchEvent(evt);
        } catch (e) { console.log('hbUltra dispatchKey error', e); }
      })();
    ''';
  }

  /// Intenta aplicar un avatar personalizado en base64. Ver nota de
  /// limitación en la cabecera del archivo.
  static String setCustomAvatar(String base64Image) {
    return '''
      (function() {
        try {
          window.__hbUltraCustomAvatar = "$base64Image";
          // Gancho genérico: si la room/host expone una API de avatar
          // (por ejemplo window.HB_setAvatar), se usa aquí.
          if (typeof window.HB_setAvatar === 'function') {
            window.HB_setAvatar(window.__hbUltraCustomAvatar);
          }
          // Fallback: guarda en localStorage por si el host lee este valor.
          localStorage.setItem('hbUltra_customAvatarBase64', window.__hbUltraCustomAvatar);
        } catch (e) { console.log('hbUltra setCustomAvatar error', e); }
      })();
    ''';
  }

  /// Restaura el avatar por defecto (limpia el gancho anterior).
  static const String resetAvatar = '''
    (function() {
      try {
        window.__hbUltraCustomAvatar = null;
        localStorage.removeItem('hbUltra_customAvatarBase64');
        if (typeof window.HB_resetAvatar === 'function') window.HB_resetAvatar();
      } catch (e) {}
    })();
  ''';

  /// Ajusta el límite de FPS del bucle de renderizado del juego mediante un
  /// wrapper de requestAnimationFrame (throttling). No modifica el motor
  /// real de HaxBall, solo limita la tasa de refresco visual desde fuera.
  static String applyFpsLimit(int fps) {
    if (fps <= 0) {
      return "window.__hbUltraFpsLimit = 0;"; // sin límite
    }
    return '''
      (function() {
        window.__hbUltraFpsLimit = $fps;
        if (window.__hbUltraRafPatched) return;
        window.__hbUltraRafPatched = true;
        var nativeRaf = window.requestAnimationFrame.bind(window);
        var lastTime = 0;
        window.requestAnimationFrame = function(cb) {
          return nativeRaf(function(ts) {
            var minDelta = 1000 / (window.__hbUltraFpsLimit || 60);
            if (ts - lastTime >= minDelta) {
              lastTime = ts;
              cb(ts);
            }
          });
        };
      })();
    ''';
  }
}
