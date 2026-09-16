import 'package:flutter/widgets.dart';

/// Traduções do Smart Tools. Base em inglês. RTL automático em árabe.
/// Idiomas: en (base) · ar (RTL) · hi · zh · pt · es.
class T {
  T(this.l);
  final String l;

  static const supported = ['en', 'ar', 'hi', 'zh', 'pt', 'es'];
  static const locales = [
    Locale('en'), Locale('ar'), Locale('hi'),
    Locale('zh'), Locale('pt'), Locale('es'),
  ];

  static T of(BuildContext c) {
    final code = Localizations.localeOf(c).languageCode;
    return T(supported.contains(code) ? code : 'en');
  }

  /// Ordem dos valores: en, ar, hi, zh, pt, es.
  String _(String en, String ar, String hi, String zh, String pt, String es) {
    switch (l) {
      case 'ar': return ar;
      case 'hi': return hi;
      case 'zh': return zh;
      case 'pt': return pt;
      case 'es': return es;
      default: return en;
    }
  }

  String get appName =>
      _('Smart Tools', 'أدوات ذكية', 'स्मार्ट टूल्स', '智能工具箱', 'Ferramentas Smart', 'Herramientas Smart');
  String get appTagline => _(
      'Your all-in-one toolbox', 'صندوق أدواتك المتكامل', 'आपका ऑल-इन-वन टूलबॉक्स',
      '你的全能工具箱', 'Sua caixa de ferramentas', 'Tu caja de herramientas');

  // ---------------- Ferramentas ----------------
  String get flashlight => _('Flashlight', 'مصباح', 'टॉर्च', '手电筒', 'Lanterna', 'Linterna');
  String get compass => _('Compass', 'بوصلة', 'कम्पास', '指南针', 'Bússola', 'Brújula');
  String get ruler => _('Ruler', 'مسطرة', 'रूलर', '尺子', 'Régua', 'Regla');
  String get level => _('Bubble Level', 'ميزان الماء', 'लेवल', '水平仪', 'Nível', 'Nivel');
  String get magnifier => _('Magnifier', 'مكبر', 'आवर्धक', '放大镜', 'Lupa', 'Lupa');
  String get mirror => _('Mirror', 'مرآة', 'दर्पण', '镜子', 'Espelho', 'Espejo');
  String get qr => _('QR Scanner', 'ماسح QR', 'क्यूआर स्कैनर', '二维码', 'Leitor QR', 'Escáner QR');
  String get converter => _('Converter', 'محول', 'कन्वर्टर', '单位换算', 'Conversor', 'Conversor');
  String get calculator => _('Calculator', 'آلة حاسبة', 'कैलकुलेटर', '计算器', 'Calculadora', 'Calculadora');
  String get stopwatch => _('Stopwatch', 'ساعة إيقاف', 'स्टॉपवॉच', '秒表', 'Cronômetro', 'Cronómetro');
  String get timer => _('Timer', 'مؤقت', 'टाइमर', '计时器', 'Timer', 'Temporizador');
  String get protractor => _('Protractor', 'منقلة', 'प्रोट्रैक्टर', '量角器', 'Transferidor', 'Transportador');
  String get soundMeter => _('Sound Meter', 'مقياس الصوت', 'ध्वनि मीटर', '噪音计', 'Medidor de som', 'Sonómetro');
  String get metalDetector => _('Metal Detector', 'كاشف المعادن', 'मेटल डिटेक्टर', '金属探测器', 'Detector de metal', 'Detector de metal');
  String get qibla => _('Qibla', 'القبلة', 'क़िबला', '朝拜方向', 'Qibla', 'Qibla');
  String get vibration => _('Vibration Meter', 'مقياس الاهتزاز', 'कंपन मीटर', '振动仪', 'Vibrômetro', 'Vibrómetro');
  String get speedometer => _('Speedometer', 'عداد السرعة', 'स्पीडोमीटर', '速度计', 'Velocímetro', 'Velocímetro');
  String get battery => _('Battery Info', 'معلومات البطارية', 'बैटरी जानकारी', '电池信息', 'Bateria', 'Batería');

  // ---------------- Conversor: categorias ----------------
  String get convLength => _('Length', 'الطول', 'लंबाई', '长度', 'Comprimento', 'Longitud');
  String get convWeight => _('Weight', 'الوزن', 'वज़न', '重量', 'Peso', 'Peso');
  String get convTemp => _('Temperature', 'الحرارة', 'तापमान', '温度', 'Temperatura', 'Temperatura');
  String get convArea => _('Area', 'المساحة', 'क्षेत्रफल', '面积', 'Área', 'Área');
  String get convVolume => _('Volume', 'الحجم', 'आयतन', '体积', 'Volume', 'Volumen');
  String get convSpeed => _('Speed', 'السرعة', 'गति', '速度', 'Velocidade', 'Velocidad');
  String get convData => _('Data', 'البيانات', 'डेटा', '数据', 'Dados', 'Datos');
  String get convTime => _('Time', 'الوقت', 'समय', '时间', 'Tempo', 'Tiempo');

  String convCat(String key) {
    switch (key) {
      case 'Length': return convLength;
      case 'Weight': return convWeight;
      case 'Temperature': return convTemp;
      case 'Area': return convArea;
      case 'Volume': return convVolume;
      case 'Speed': return convSpeed;
      case 'Data': return convData;
      case 'Time': return convTime;
      default: return key;
    }
  }

  // ---------------- Categorias (home) ----------------
  String get catMeasure => _('Measure', 'قياس', 'मापें', '测量', 'Medir', 'Medir');
  String get catSensors => _('Sensors', 'المستشعرات', 'सेंसर', '传感器', 'Sensores', 'Sensores');
  String get catEveryday => _('Everyday', 'يومي', 'रोज़मर्रा', '日常', 'Dia a dia', 'Diario');

  // ---------------- Comuns ----------------
  String get on => _('On', 'تشغيل', 'चालू', '开', 'Ligado', 'Encendido');
  String get off => _('Off', 'إيقاف', 'बंद', '关', 'Desligado', 'Apagado');
  String get sos => _('SOS', 'استغاثة', 'एसओएस', 'SOS', 'SOS', 'SOS');
  String get strobe => _('Strobe', 'وميض', 'स्ट्रोब', '频闪', 'Estroboscópio', 'Estroboscopio');
  String get start => _('Start', 'ابدأ', 'शुरू', '开始', 'Iniciar', 'Iniciar');
  String get stop => _('Stop', 'إيقاف', 'रोकें', '停止', 'Parar', 'Parar');
  String get pause => _('Pause', 'إيقاف مؤقت', 'रोकें', '暂停', 'Pausar', 'Pausar');
  String get reset => _('Reset', 'إعادة', 'रीसेट', '重置', 'Zerar', 'Reiniciar');
  String get lap => _('Lap', 'لفة', 'लैप', '计次', 'Volta', 'Vuelta');
  String get save => _('Save', 'حفظ', 'सहेजें', '保存', 'Salvar', 'Guardar');
  String get clear => _('Clear', 'مسح', 'साफ़', '清除', 'Limpar', 'Borrar');
  String get copy => _('Copy', 'نسخ', 'कॉपी', '复制', 'Copiar', 'Copiar');
  String get open => _('Open', 'فتح', 'खोलें', '打开', 'Abrir', 'Abrir');
  String get copied => _('Copied', 'تم النسخ', 'कॉपी किया', '已复制', 'Copiado', 'Copiado');
  String get share => _('Share', 'مشاركة', 'शेयर', '分享', 'Compartilhar', 'Compartir');
  String get history => _('History', 'السجل', 'इतिहास', '历史', 'Histórico', 'Historial');
  String get export => _('Export', 'تصدير', 'निर्यात', '导出', 'Exportar', 'Exportar');
  String get min => _('Min', 'أدنى', 'न्यून', '最小', 'Mín', 'Mín');
  String get max => _('Max', 'أقصى', 'अधिक', '最大', 'Máx', 'Máx');
  String get avg => _('Avg', 'متوسط', 'औसत', '平均', 'Méd', 'Prom');
  String get current => _('Now', 'الآن', 'अभी', '当前', 'Agora', 'Ahora');

  String get calibrate => _('Calibrate the compass by moving the phone in a figure 8.',
      'عاير البوصلة بتحريك الهاتف على شكل 8.', 'फोन को 8 आकार में घुमाकर कम्पास कैलिब्रेट करें।',
      '以8字形移动手机以校准指南针。', 'Calibre movendo o celular em forma de 8.',
      'Calibra moviendo el teléfono en forma de 8.');
  String get pointNorth => _('N', 'ش', 'उ', '北', 'N', 'N');

  // ---------------- Medidor de som ----------------
  String get decibels => _('Decibels', 'ديسيبل', 'डेसिबल', '分贝', 'Decibéis', 'Decibelios');
  String get listening => _('Listening…', 'يستمع…', 'सुन रहा है…', '正在聆听…', 'Ouvindo…', 'Escuchando…');
  String get record => _('Record', 'تسجيل', 'रिकॉर्ड', '录制', 'Gravar', 'Grabar');
  String get recording => _('Recording…', 'يسجل…', 'रिकॉर्डिंग…', '录制中…', 'Gravando…', 'Grabando…');
  String get exportCsv => _('Export CSV', 'تصدير CSV', 'CSV निर्यात', '导出 CSV',
      'Exportar CSV', 'Exportar CSV');
  String get samples => _('samples', 'عينات', 'नमूने', '样本', 'amostras', 'muestras');

  // ---------------- Detector de metal ----------------
  String get magneticField => _('Magnetic field', 'المجال المغناطيسي', 'चुंबकीय क्षेत्र',
      '磁场', 'Campo magnético', 'Campo magnético');
  String get metalNear => _('Metal detected!', 'تم رصد معدن!', 'धातु मिली!',
      '检测到金属！', 'Metal detectado!', '¡Metal detectado!');

  // ---------------- Qibla ----------------
  String get qiblaHint => _('Rotate until the arrow points up — that is the Qibla.',
      'أدر حتى يشير السهم للأعلى — هذا اتجاه القبلة.',
      'तीर ऊपर होने तक घुमाएँ — वही क़िबला है।',
      '旋转手机直到箭头朝上，即为朝拜方向。',
      'Gire até a seta apontar para cima — essa é a Qibla.',
      'Gira hasta que la flecha apunte arriba — esa es la Qibla.');
  String get findingLocation => _('Finding your location…', 'يحدد موقعك…', 'स्थान खोज रहा है…',
      '正在定位…', 'Localizando…', 'Ubicando…');

  // ---------------- Velocímetro ----------------
  String get speedNow => _('Speed', 'السرعة', 'गति', '速度', 'Velocidade', 'Velocidad');
  String get distance => _('Distance', 'المسافة', 'दूरी', '距离', 'Distância', 'Distancia');
  String get waitingGps => _('Waiting for GPS…', 'بانتظار GPS…', 'GPS का इंतज़ार…',
      '等待 GPS…', 'Aguardando GPS…', 'Esperando GPS…');

  // ---------------- Bateria ----------------
  String get batteryLevel => _('Level', 'المستوى', 'स्तर', '电量', 'Nível', 'Nivel');
  String get batteryStatus => _('Status', 'الحالة', 'स्थिति', '状态', 'Status', 'Estado');
  String get charging => _('Charging', 'يشحن', 'चार्ज हो रहा', '充电中', 'Carregando', 'Cargando');
  String get discharging => _('On battery', 'على البطارية', 'बैटरी पर', '使用电池', 'Na bateria', 'En batería');
  String get full => _('Full', 'ممتلئة', 'पूर्ण', '已充满', 'Cheia', 'Completa');

  // ---------------- Timer ----------------
  String get timesUp => _("Time's up!", 'انتهى الوقت!', 'समय समाप्त!', '时间到！',
      'Tempo esgotado!', '¡Tiempo terminado!');

  // ---------------- Ajustes ----------------
  String get settings => _('Settings', 'الإعدادات', 'सेटिंग्स', '设置', 'Ajustes', 'Ajustes');
  String get darkMode => _('Dark mode', 'الوضع الداكن', 'डार्क मोड', '深色模式', 'Modo escuro', 'Modo oscuro');
  String get measurement => _('Measurement units', 'وحدات القياس', 'माप इकाइयाँ',
      '测量单位', 'Unidades de medida', 'Unidades de medida');
  String get unitsAuto => _('Automatic (region)', 'تلقائي (المنطقة)', 'स्वचालित (क्षेत्र)',
      '自动（地区）', 'Automático (região)', 'Automático (región)');
  String get unitsMetric => _('Metric (m, kg, °C)', 'متري (م، كغ، °م)', 'मीट्रिक (m, kg, °C)',
      '公制 (m, kg, °C)', 'Métrico (m, kg, °C)', 'Métrico (m, kg, °C)');
  String get unitsImperial => _('Imperial (ft, lb, °F)', 'إمبراطوري (قدم، رطل، °ف)',
      'इंपीरियल (ft, lb, °F)', '英制 (ft, lb, °F)', 'Imperial (ft, lb, °F)', 'Imperial (ft, lb, °F)');
  String get rateUs => _('Rate us', 'قيّمنا', 'हमें रेट करें', '给我们评分', 'Avaliar', 'Califícanos');
  String get restore => _('Restore purchases', 'استعادة المشتريات', 'खरीद पुनर्स्थापित करें',
      '恢复购买', 'Restaurar compras', 'Restaurar compras');

  // ---------------- Premium / Pro ----------------
  String get proTitle => _('Smart Tools Pro', 'أدوات ذكية برو', 'स्मार्ट टूल्स प्रो',
      '智能工具箱 Pro', 'Smart Tools Pro', 'Smart Tools Pro');
  String get proSubtitle => _('One upgrade. Every tool, no ads, forever better.',
      'ترقية واحدة. كل الأدوات، بلا إعلانات.', 'एक अपग्रेड। सभी टूल्स, कोई विज्ञापन नहीं।',
      '一次升级，全部工具，永无广告。', 'Um upgrade. Todas as ferramentas, sem anúncios.',
      'Una mejora. Todas las herramientas, sin anuncios.');
  String get goPro => _('Go Pro', 'اشترك الآن', 'प्रो पाएं', '升级 Pro', 'Seja Pro', 'Hazte Pro');
  String get monthly => _('Monthly', 'شهري', 'मासिक', '每月', 'Mensal', 'Mensual');
  String get yearly => _('Yearly', 'سنوي', 'वार्षिक', '每年', 'Anual', 'Anual');
  String get lifetime => _('Lifetime', 'مدى الحياة', 'लाइफटाइम', '永久', 'Vitalício', 'De por vida');
  String get bestValue => _('Best value', 'الأفضل', 'सर्वोत्तम', '最超值', 'Melhor oferta', 'Mejor valor');
  String get oneTime => _('one-time', 'دفعة واحدة', 'एक बार', '一次性', 'pagamento único', 'pago único');
  String get perMonth => _('/mo', '/شهر', '/माह', '/月', '/mês', '/mes');
  String get perYear => _('/yr', '/سنة', '/वर्ष', '/年', '/ano', '/año');
  String get subscribe => _('Continue', 'متابعة', 'जारी रखें', '继续', 'Continuar', 'Continuar');
  String get proBadge => _('PRO', 'برو', 'प्रो', 'PRO', 'PRO', 'PRO');
  String get maybeLater => _('Maybe later', 'لاحقًا', 'बाद में', '以后再说', 'Depois', 'Más tarde');

  // Benefícios Pro
  String get featNoAds => _('Remove all ads', 'إزالة كل الإعلانات', 'सभी विज्ञापन हटाएँ',
      '去除所有广告', 'Remover todos os anúncios', 'Quitar todos los anuncios');
  String get featAllTools => _('Unlock every Pro tool', 'فتح كل أدوات برو', 'सभी प्रो टूल अनलॉक',
      '解锁全部 Pro 工具', 'Desbloquear todas as ferramentas Pro', 'Desbloquea todas las herramientas Pro');
  String get featRecord => _('Record & save measurements', 'تسجيل وحفظ القياسات',
      'माप रिकॉर्ड और सहेजें', '记录并保存测量', 'Gravar e salvar medições', 'Graba y guarda mediciones');
  String get featExport => _('Export history (CSV)', 'تصدير السجل (CSV)', 'इतिहास निर्यात (CSV)',
      '导出历史 (CSV)', 'Exportar histórico (CSV)', 'Exporta historial (CSV)');
  String get featPrecision => _('Precision & calibration', 'دقة ومعايرة', 'सटीकता और कैलिब्रेशन',
      '精度与校准', 'Precisão e calibração', 'Precisión y calibración');
  String get proToolLocked => _('This is a Pro tool', 'هذه أداة برو', 'यह एक प्रो टूल है',
      '这是 Pro 工具', 'Esta é uma ferramenta Pro', 'Esta es una herramienta Pro');
  String get unlockToUse => _('Unlock to use', 'افتح للاستخدام', 'उपयोग हेतु अनलॉक',
      '解锁使用', 'Desbloquear para usar', 'Desbloquear para usar');

  // ---------------- Permissões ----------------
  String get needCamera => _('Camera permission is needed.', 'يلزم إذن الكاميرا.',
      'कैमरा अनुमति चाहिए।', '需要相机权限。', 'É preciso permitir a câmera.',
      'Se necesita permiso de cámara.');
  String get needMic => _('Microphone permission is needed.', 'يلزم إذن الميكروفون.',
      'माइक्रोफ़ोन अनुमति चाहिए।', '需要麦克风权限。', 'É preciso permitir o microfone.',
      'Se necesita permiso de micrófono.');
  String get needLocation => _('Location permission is needed.', 'يلزم إذن الموقع.',
      'स्थान अनुमति चाहिए।', '需要位置权限。', 'É preciso permitir a localização.',
      'Se necesita permiso de ubicación.');
  String get grant => _('Grant permission', 'منح الإذن', 'अनुमति दें', '授予权限',
      'Conceder permissão', 'Conceder permiso');
  String get openSettings => _('Open settings', 'فتح الإعدادات', 'सेटिंग्स खोलें',
      '打开设置', 'Abrir ajustes', 'Abrir ajustes');
}
