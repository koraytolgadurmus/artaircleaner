// lib/main.dart – ArtAirCleaner (Sprint-2, compact mode buttons + collapsible RGB)
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ArtAirCleanerApp());
}

class I18n {
  final String code;
  I18n(this.code);

  static const supported = {
    'en': 'English',
    'tr': 'Türkçe',
    'de': 'Deutsch',
    'es': 'Español',
    'fr': 'Français',
    'it': 'Italiano',
    'ru': 'Русский',
    'ar': 'العربية',
    'pt': 'Português',
    'zh': '中文 (简体)',
  };

  static const _rtl = {'ar'};
  bool get isRTL => _rtl.contains(code);

  String t(String k) => _map[code]?[k] ?? _map['en']![k]!;

  static final _map = {
    'en': {
      'title':'ArtAirCleaner','home':'Home','sensors':'Sensors','planner':'Planner','settings':'Settings',
      'master':'Master','power':'Power','mode':'Mode','sleep':'Sleep','low':'Low','med':'Med','high':'High','turbo':'Turbo','auto':'Auto',
      'fan_speed':'Fan Speed','ignored_in_auto':'Manual (ignored in Auto)','light':'Light','clean':'Clean/UV','ion':'Ionizer',
      'flame':'Frame Light','device_not':'Device is not reachable',
      'device_not_hint':'Set Base URL in Settings and ensure ESP32 is on the same LAN.',
      'base_url':'Base URL','base_url_hint':'ESP32 address (e.g., http://192.168.1.50)',
      'save':'Save','test':'Test','refresh':'Refresh',
      'reachable_yes':'Device reachable ✅','reachable_no':'Device NOT reachable ❌',
      'mq4_alarm':'MQ-4 Alarm','enable_mq4':'Enable MQ-4 Alarm','threshold':'Threshold (V)',
      'appearance':'Appearance','theme':'Theme','language':'Language',
      'rpm':'RPM','pm':'PM (V)','mq4':'MQ-4 (V)','temp':'Temp (°C)','hum':'Humidity (%)',
      'filter_care':'Filter Care','calibrate':'Calibrate','test_run':'Test',
      'calibrating':'Calibrating...','testing':'Testing...','filter_ok':'Filter looks OK',
      'filter_bad':'Filter needs replacement','red_warning':'Filter replacement recommended!','run':'Run',
      'sync_time':'Sync Time','add_plan':'Add Plan','no_plan':'No plans yet. Add one.',
      'dialog_title':'Language','dialog_msg':'Please choose a language',
      'start':'Start','end':'End','plan_speed':'Speed for this plan: ',
      'cancel':'Cancel','theme_light':'Light','theme_dark':'Dark',
      'ok':'OK','command_failed':'Command failed',
      'filter_alert_title':'Replace / calibrate filter',
      'filter_alert_subtitle':'Detected RPM drop ≥ 20%',
    },
    'tr': {
      'title':'ArtAirCleaner','home':'Ana Sayfa','sensors':'Sensörler','planner':'Planlayıcı','settings':'Ayarlar',
      'master':'Ana Güç','power':'Güç','mode':'Mod','sleep':'Uyku','low':'Düşük','med':'Orta','high':'Yüksek','turbo':'Turbo','auto':'Oto',
      'fan_speed':'Fan Hızı','ignored_in_auto':'Manuel (Oto modda yok sayılır)','light':'Aydınlatma','clean':'Temizleme/UV','ion':'İyonizer',
      'flame':'Çerçeve Işığı','device_not':'Cihaz erişilemiyor',
      'device_not_hint':'Ayarlar’dan Base URL girin ve ESP32 ile aynı ağda olun.',
      'base_url':'Base URL','base_url_hint':'ESP32 adresi (örn. http://192.168.1.50)',
      'save':'Kaydet','test':'Test','refresh':'Yenile',
      'reachable_yes':'Cihaz erişilebilir ✅','reachable_no':'Cihaz erişilemiyor ❌',
      'mq4_alarm':'MQ-4 Alarmı','enable_mq4':'MQ-4 Alarmını Aç','threshold':'Eşik (V)',
      'appearance':'Görünüm','theme':'Tema','language':'Dil',
      'rpm':'RPM','pm':'PM (V)','mq4':'MQ-4 (V)','temp':'Sıcaklık (°C)','hum':'Nem (%)',
      'filter_care':'Filtre Bakımı','calibrate':'Kalibre Et','test_run':'Test Et',
      'calibrating':'Kalibre ediliyor...','testing':'Test ediliyor...','filter_ok':'Filtre iyi görünüyor',
      'filter_bad':'Filtre değişmeli','red_warning':'Filtre değişimi önerilir!','run':'Çalıştır',
      'sync_time':'Zamanı Eşitle','add_plan':'Plan Ekle','no_plan':'Henüz plan yok. Plan Ekle ile ekleyin.',
      'dialog_title':'Dil','dialog_msg':'Lütfen bir dil seçin',
      'start':'Başlangıç','end':'Bitiş','plan_speed':'Bu plan için hız: ',
      'cancel':'İptal','theme_light':'Açık','theme_dark':'Koyu',
      'ok':'Tamam','command_failed':'Komut başarısız',
      'filter_alert_title':'Filtreyi değiştirin / kalibre edin',
      'filter_alert_subtitle':'%20 ve üzeri RPM düşüşü algılandı',
    },
    // (diğer diller aynı kaldı – kısaltmak için çıkarılmadı)
    'de': {'title':'ArtAirCleaner','home':'Start','sensors':'Sensoren','planner':'Planer','settings':'Einstellungen','master':'Hauptschalter','power':'Hauptschalter','mode':'Modus','sleep':'Leise','low':'Niedrig','med':'Mittel','high':'Hoch','turbo':'Turbo','auto':'Auto','fan_speed':'Lüftergeschwindigkeit','ignored_in_auto':'Manuell (in Auto ignoriert)','light':'Licht','clean':'Reinigung/UV','ion':'Ionisator','flame':'Rahmenlicht','device_not':'Gerät nicht erreichbar','device_not_hint':'Base-URL in Einstellungen setzen und sicherstellen, dass ESP32 im selben LAN ist.','base_url':'Base-URL','base_url_hint':'ESP32-Adresse (z. B. http://192.168.1.50)','save':'Speichern','test':'Test','refresh':'Aktualisieren','reachable_yes':'Gerät erreichbar ✅','reachable_no':'Gerät NICHT erreichbar ❌','mq4_alarm':'MQ-4 Alarm','enable_mq4':'MQ-4 Alarm aktivieren','threshold':'Schwelle (V)','appearance':'Darstellung','theme':'Thema','language':'Sprache','rpm':'RPM','pm':'PM (V)','mq4':'MQ-4 (V)','temp':'Temp (°C)','hum':'Luftfeuchte (%)','filter_care':'Filterpflege','calibrate':'Kalibrieren','test_run':'Test','calibrating':'Kalibriere...','testing':'Teste...','filter_ok':'Filter in Ordnung','filter_bad':'Filter muss gewechselt werden','red_warning':'Filterwechsel empfohlen!','run':'Start','sync_time':'Zeit synchronisieren','add_plan':'Plan hinzufügen','no_plan':'Noch kein Plan. Füge einen hinzu.','dialog_title':'Sprache','dialog_msg':'Bitte Sprache wählen','start':'Start','end':'Ende','plan_speed':'Geschwindigkeit für diesen Plan: ','cancel':'Abbrechen','theme_light':'Hell','theme_dark':'Dunkel','ok':'OK','command_failed':'Befehl fehlgeschlagen','filter_alert_title':'Filter wechseln / kalibrieren','filter_alert_subtitle':'RPM-Abfall ≥ 20% erkannt',},
    'es': {'title':'ArtAirCleaner','home':'Inicio','sensors':'Sensores','planner':'Programador','settings':'Ajustes','master':'Principal','power':'Principal','mode':'Modo','sleep':'Sueño','low':'Bajo','med':'Medio','high':'Alto','turbo':'Turbo','auto':'Auto','fan_speed':'Velocidad del ventilador','ignored_in_auto':'Manual (ignorado en Auto)','light':'Luz','clean':'Limpieza/UV','ion':'Ionizador','flame':'Luz de marco','device_not':'Dispositivo inaccesible','device_not_hint':'Configura la URL base y asegúrate de que el ESP32 esté en la misma red.','base_url':'URL base','base_url_hint':'Dirección ESP32 (p. ej., http://192.168.1.50)','save':'Guardar','test':'Probar','refresh':'Actualizar','reachable_yes':'Dispositivo accesible ✅','reachable_no':'Dispositivo NO accesible ❌','mq4_alarm':'Alarma MQ-4','enable_mq4':'Activar alarma MQ-4','threshold':'Umbral (V)','appearance':'Apariencia','theme':'Tema','language':'Idioma','rpm':'RPM','pm':'PM (V)','mq4':'MQ-4 (V)','temp':'Temp (°C)','hum':'Humedad (%)','filter_care':'Cuidado del filtro','calibrate':'Calibrar','test_run':'Prueba','calibrating':'Calibrando...','testing':'Probando...','filter_ok':'Filtro en buen estado','filter_bad':'Reemplazar filtro','red_warning':'¡Se recomienda reemplazar el filtro!','run':'Ejecutar','sync_time':'Sincronizar hora','add_plan':'Añadir plan','no_plan':'Sin planes. Añade uno.','dialog_title':'Idioma','dialog_msg':'Elige un idioma','start':'Inicio','end':'Fin','plan_speed':'Velocidad para este plan: ','cancel':'Cancelar','theme_light':'Claro','theme_dark':'Oscuro','ok':'OK','command_failed':'Comando fallido','filter_alert_title':'Reemplaza / calibra el filtro','filter_alert_subtitle':'Caída de RPM ≥ 20% detectada',},
    'fr': {'title':'ArtAirCleaner','home':'Accueil','sensors':'Capteurs','planner':'Planificateur','settings':'Réglages','master':'Principal','power':'Principal','mode':'Mode','sleep':'Veille','low':'Bas','med':'Moyen','high':'Élevé','turbo':'Turbo','auto':'Auto','fan_speed':'Vitesse du ventilateur','ignored_in_auto':'Manuel (ignoré en Auto)','light':'Lumière','clean':'Nettoyage/UV','ion':'Ioniseur','flame':'Lumière du cadre','device_not':'Appareil inaccessible','device_not_hint':'Définissez la Base URL et assurez-vous que l’ESP32 est sur le même réseau.','base_url':'Base URL','base_url_hint':'Adresse ESP32 (ex. http://192.168.1.50)','save':'Enregistrer','test':'Tester','refresh':'Rafraîchir','reachable_yes':'Appareil accessible ✅','reachable_no':'Appareil INaccessible ❌','mq4_alarm':'Alarme MQ-4','enable_mq4':'Activer alarme MQ-4','threshold':'Seuil (V)','appearance':'Apparence','theme':'Thème','language':'Langue','rpm':'RPM','pm':'PM (V)','mq4':'MQ-4 (V)','temp':'Temp (°C)','hum':'Humidité (%)','filter_care':'Entretien du filtre','calibrate':'Étalonner','test_run':'Test','calibrating':'Étalonnage...','testing':'Test en cours...','filter_ok':'Filtre correct','filter_bad':'Remplacer le filtre','red_warning':'Remplacement du filtre recommandé !','run':'Exécuter','sync_time':'Synchroniser l’heure','add_plan':'Ajouter un plan','no_plan':'Aucun plan. Ajoutez-en un.','dialog_title':'Langue','dialog_msg':'Choisissez une langue','start':'Début','end':'Fin','plan_speed':'Vitesse pour ce plan : ','cancel':'Annuler','theme_light':'Clair','theme_dark':'Sombre','ok':'OK','command_failed':'Commande échouée','filter_alert_title':'Remplacez / étalonnez le filtre','filter_alert_subtitle':'Baisse des RPM ≥ 20% détectée',},
    'it': {'title':'ArtAirCleaner','home':'Home','sensors':'Sensori','planner':'Pianificatore','settings':'Impostazioni','master':'Principale','power':'Principale','mode':'Modalità','sleep':'Notte','low':'Basso','med':'Medio','high':'Alto','turbo':'Turbo','auto':'Auto','fan_speed':'Velocità ventola','ignored_in_auto':'Manuale (ignorato in Auto)','light':'Luce','clean':'Pulizia/UV','ion':'Ionizzatore','flame':'Luce cornice','device_not':'Dispositivo non raggiungibile','device_not_hint':'Imposta la Base URL e assicurati che l’ESP32 sia sulla stessa rete.','base_url':'Base URL','base_url_hint':'Indirizzo ESP32 (es. http://192.168.1.50)','save':'Salva','test':'Test','refresh':'Aggiorna','reachable_yes':'Dispositivo raggiungibile ✅','reachable_no':'Dispositivo NON raggiungibile ❌','mq4_alarm':'Allarme MQ-4','enable_mq4':'Abilita allarme MQ-4','threshold':'Soglia (V)','appearance':'Aspetto','theme':'Tema','language':'Lingua','rpm':'RPM','pm':'PM (V)','mq4':'MQ-4 (V)','temp':'Temp (°C)','hum':'Umidità (%)','filter_care':'Manutenzione filtro','calibrate':'Calibra','test_run':'Test','calibrating':'Calibrazione...','testing':'Test in corso...','filter_ok':'Filtro a posto','filter_bad':'Sostituire il filtro','red_warning':'Consigliata la sostituzione del filtro!','run':'Avvia','sync_time':'Sincronizza ora','add_plan':'Aggiungi piano','no_plan':'Nessun piano. Aggiungine uno.','dialog_title':'Lingua','dialog_msg':'Scegli una lingua','start':'Inizio','end':'Fine','plan_speed':'Velocità per questo piano: ','cancel':'Annulla','theme_light':'Chiaro','theme_dark':'Scuro','ok':'OK','command_failed':'Comando non riuscito','filter_alert_title':'Sostituisci / calibra il filtro','filter_alert_subtitle':'Rilevato calo RPM ≥ 20%',},
    'ru': {'title':'ArtAirCleaner','home':'Главная','sensors':'Датчики','planner':'Планировщик','settings':'Настройки','master':'Питание','power':'Питание','mode':'Режим','sleep':'Тихий','low':'Низкий','med':'Средний','high':'Высокий','turbo':'Турбо','auto':'Авто','fan_speed':'Скорость вентилятора','ignored_in_auto':'Вручную (в Авто игнор.)','light':'Подсветка','clean':'Очистка/UV','ion':'Ионизатор','flame':'Подсветка рамки','device_not':'Устройство недоступно','device_not_hint':'Укажите Base URL и убедитесь, что ESP32 в той же сети.','base_url':'Base URL','base_url_hint':'Адрес ESP32 (напр. http://192.168.1.50)','save':'Сохранить','test':'Тест','refresh':'Обновить','reachable_yes':'Устройство доступно ✅','reachable_no':'Устройство НЕДОСТУПНО ❌','mq4_alarm':'Сигнал MQ-4','enable_mq4':'Включить MQ-4','threshold':'Порог (В)','appearance':'Вид','theme':'Тема','language':'Язык','rpm':'RPM','pm':'PM (В)','mq4':'MQ-4 (В)','temp':'Темп (°C)','hum':'Влажн (%)','filter_care':'Фильтр','calibrate':'Калибровать','test_run':'Тест','calibrating':'Калибровка...','testing':'Тестирование...','filter_ok':'Фильтр в норме','filter_bad':'Требуется замена фильтра','red_warning':'Рекомендуется заменить фильтр!','run':'Пуск','sync_time':'Синхр. времени','add_plan':'Добавить план','no_plan':'Планов нет. Добавьте.','dialog_title':'Язык','dialog_msg':'Выберите язык','start':'Начало','end':'Конец','plan_speed':'Скорость для этого плана: ','cancel':'Отмена','theme_light':'Светлая','theme_dark':'Тёмная','ok':'OK','command_failed':'Команда не выполнена','filter_alert_title':'Замените / калибруйте фильтр','filter_alert_subtitle':'Обнаружено падение оборотов ≥ 20%',},
    'ar': {'title':'منقّي الهواء','home':'الرئيسية','sensors':'المستشعرات','planner':'الجدولة','settings':'الإعدادات','master':'الطاقة','power':'الطاقة','mode':'الوضع','sleep':'هادئ','low':'منخفض','med':'متوسط','high':'عالٍ','turbo':'توربو','auto':'تلقائي','fan_speed':'سرعة المروحة','ignored_in_auto':'يدوي (يتجاهله التلقائي)','light':'الإضاءة','clean':'تنظيف/أشعة UV','ion':'مؤين','flame':'إضاءة الإطار','device_not':'الجهاز غير متاح','device_not_hint':'أدخل العنوان الأساسي وتأكد أن ESP32 على نفس الشبكة.','base_url':'العنوان الأساسي','base_url_hint':'عنوان ESP32 (مثال http://192.168.1.50)','save':'حفظ','test':'اختبار','refresh':'تحديث','reachable_yes':'الجهاز متاح ✅','reachable_no':'الجهاز غير متاح ❌','mq4_alarm':'إنذار MQ-4','enable_mq4':'تفعيل إنذار MQ-4','threshold':'العتبة (فولت)','appearance':'المظهر','theme':'السمة','language':'اللغة','rpm':'RPM','pm':'PM (فولت)','mq4':'MQ-4 (فولت)','temp':'حرارة (°م)','hum':'رطوبة (%)','filter_care':'العناية بالفلتر','calibrate':'معايرة','test_run':'اختبار','calibrating':'جارٍ المعايرة...','testing':'جارٍ الاختبار...','filter_ok':'الفلتر جيد','filter_bad':'يلزم استبدال الفلتر','red_warning':'يوصى باستبدال الفلتر!','run':'تشغيل','sync_time':'مزامنة الوقت','add_plan':'إضافة خطة','no_plan':'لا توجد خطط. أضف واحدة.','dialog_title':'اللغة','dialog_msg':'اختر لغة','start':'البدء','end':'الانتهاء','plan_speed':'السرعة لهذه الخطة: ','cancel':'إلغاء','theme_light':'فاتح','theme_dark':'داكن','ok':'حسنًا','command_failed':'فشل الأمر','filter_alert_title':'استبدل/عاير الفلتر','filter_alert_subtitle':'تم رصد انخفاض RPM ≥ 20%',},
    'pt': {'title':'ArtAirCleaner','home':'Início','sensors':'Sensores','planner':'Agendador','settings':'Configurações','master':'Principal','power':'Principal','mode':'Modo','sleep':'Silencioso','low':'Baixo','med':'Médio','high':'Alto','turbo':'Turbo','auto':'Auto','fan_speed':'Velocidade do ventilador','ignored_in_auto':'Manual (ignorado no Auto)','light':'Luz','clean':'Limpeza/UV','ion':'Ionizador','flame':'Luz da moldura','device_not':'Dispositivo inacessível','device_not_hint':'Defina a URL base e garanta que o ESP32 esteja na mesma rede.','base_url':'URL base','base_url_hint':'Endereço do ESP32 (ex.: http://192.168.1.50)','save':'Salvar','test':'Testar','refresh':'Atualizar','reachable_yes':'Dispositivo acessível ✅','reachable_no':'Dispositivo NÃO acessível ❌','mq4_alarm':'Alarme MQ-4','enable_mq4':'Ativar alarme MQ-4','threshold':'Limite (V)','appearance':'Aparência','theme':'Tema','language':'Idioma','rpm':'RPM','pm':'PM (V)','mq4':'MQ-4 (V)','temp':'Temp (°C)','hum':'Umidade (%)','filter_care':'Cuidado do filtro','calibrate':'Calibrar','test_run':'Teste','calibrating':'Calibrando...','testing':'Testando...','filter_ok':'Filtro OK','filter_bad':'Trocar filtro','red_warning':'Recomendado trocar o filtro!','run':'Executar','sync_time':'Sincronizar hora','add_plan':'Adicionar plano','no_plan':'Sem planos. Adicione um.','dialog_title':'Idioma','dialog_msg':'Escolha um idioma','start':'Início','end':'Fim','plan_speed':'Velocidade para este plano: ','cancel':'Cancelar','theme_light':'Claro','theme_dark':'Escuro','ok':'OK','command_failed':'Falha no comando','filter_alert_title':'Troque / calibre o filtro','filter_alert_subtitle':'Queda de RPM ≥ 20% detectada',},
    'zh': {'title':'ArtAirCleaner','home':'首页','sensors':'传感器','planner':'计划','settings':'设置','master':'电源','power':'电源','mode':'模式','sleep':'静音','low':'低','med':'中','high':'高','turbo':'强力','auto':'自动','fan_speed':'风扇速度','ignored_in_auto':'手动（自动模式忽略）','light':'灯光','clean':'清洁/紫外','ion':'离子','flame':'边框灯','device_not':'设备不可访问','device_not_hint':'在设置中填写 Base URL，并确保 ESP32 在同一局域网。','base_url':'Base URL','base_url_hint':'ESP32 地址（如 http://192.168.1.50）','save':'保存','test':'测试','refresh':'刷新','reachable_yes':'设备可访问 ✅','reachable_no':'设备不可访问 ❌','mq4_alarm':'MQ-4 报警','enable_mq4':'启用 MQ-4 报警','threshold':'阈值 (V)','appearance':'外观','theme':'主题','language':'语言','rpm':'转速','pm':'PM (V)','mq4':'MQ-4 (V)','temp':'温度 (°C)','hum':'湿度 (%)','filter_care':'滤芯维护','calibrate':'校准','test_run':'测试','calibrating':'正在校准...','testing':'正在测试...','filter_ok':'滤芯正常','filter_bad':'需要更换滤芯','red_warning':'建议更换滤芯！','run':'运行','sync_time':'同步时间','add_plan':'添加计划','no_plan':'暂无计划，请添加。','dialog_title':'语言','dialog_msg':'请选择语言','start':'开始','end':'结束','plan_speed':'此计划的速度：','cancel':'取消','theme_light':'浅色','theme_dark':'深色','ok':'好的','command_failed':'命令失败','filter_alert_title':'更换/校准滤芯','filter_alert_subtitle':'检测到转速下降≥20%',},
  };
}

class ArtAirCleanerApp extends StatefulWidget {
  const ArtAirCleanerApp({super.key});
  @override
  State<ArtAirCleanerApp> createState() => _ArtAirCleanerAppState();
}

class _ArtAirCleanerAppState extends State<ArtAirCleanerApp> {
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.dark);
  final ValueNotifier<String> _lang = ValueNotifier('tr');

  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureLanguageSelected();
    });
  }

  Future<void> _ensureLanguageSelected() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getString('lang');
    final supported = I18n.supported.keys.toList();

    if (saved != null && supported.contains(saved)) {
      _lang.value = saved;
      return;
    }

    final ctx = _navKey.currentContext;
    if (ctx == null) return;

    final choice = await showDialog<String>(
      context: ctx,
      barrierDismissible: false,
      builder: (dCtx) {
        final entries = I18n.supported.entries.toList();
        return AlertDialog(
          title: Text(I18n(_lang.value).t('dialog_title')),
          content: SizedBox(
            width: 360,
            height: 360,
            child: ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final code = entries[i].key;
                final name = entries[i].value;
                return ListTile(
                  title: Text(name),
                  trailing: Text(code.toUpperCase()),
                  onTap: () => Navigator.pop(dCtx, code),
                );
              },
            ),
          ),
        );
      },
    );

    if (choice != null && supported.contains(choice)) {
      await p.setString('lang', choice);
      _lang.value = choice;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _lang,
      builder: (_, code, __) {
        final i18n = I18n(code);
        return Directionality(
          textDirection: I18n(code).isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: _themeMode,
            builder: (_, mode, __) {
              return MaterialApp(
                navigatorKey: _navKey,
                title: i18n.t('title'),
                themeMode: mode,
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light),
                  useMaterial3: true,
                ),
                darkTheme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
                  useMaterial3: true,
                ),
                home: HomeScreen(
                  i18n: i18n,
                  onThemeChanged: (m) => _themeMode.value = m,
                  onLanguageChanged: (c) async {
                    _lang.value = c;
                    final p = await SharedPreferences.getInstance();
                    await p.setString('lang', c);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ===== Models / API =====
class DeviceState {
  bool masterOn, lightOn, cleanOn, ionOn;
  int mode, fanPercent;
  int r, g, b;
  bool rgbOn;
  int rgbBrightness; // 0..100
  double pm, mq4V, tempC, hum;
  int rpm;
  bool mq4AlarmEnabled;
  double mq4AlarmThresh;
  List<int> calibRPM;
  bool filterAlert;

  DeviceState({
    required this.masterOn, required this.lightOn, required this.cleanOn, required this.ionOn,
    required this.mode, required this.fanPercent,
    required this.r, required this.g, required this.b,
    required this.rgbOn, required this.rgbBrightness,
    required this.pm, required this.mq4V, required this.tempC, required this.hum,
    required this.rpm,
    required this.mq4AlarmEnabled, required this.mq4AlarmThresh,
    required this.calibRPM, required this.filterAlert,
  });

  factory DeviceState.fromJson(Map<String, dynamic> j) => DeviceState(
    masterOn: j['masterOn'] ?? true,
    lightOn : j['lightOn'] ?? false,
    cleanOn : j['cleanOn'] ?? false,
    ionOn   : j['ionOn'] ?? false,
    mode    : j['mode'] ?? 1,
    fanPercent: j['fanPercent'] ?? 35,
    r: (j['rgb']?['r'] ?? 0),
    g: (j['rgb']?['g'] ?? 0),
    b: (j['rgb']?['b'] ?? 0),
    rgbOn: (j['rgb']?['on'] ?? false),
    rgbBrightness: (j['rgb']?['brightness'] ?? 100),
    pm: (j['pm'] ?? 0.0).toDouble(),
    mq4V: (j['mq4V'] ?? 0.0).toDouble(),
    tempC: (j['tempC'] ?? 0.0).toDouble(),
    hum: (j['hum'] ?? 0.0).toDouble(),
    rpm: (j['rpm'] ?? 0).toInt(),
    mq4AlarmEnabled: j['mq4AlarmEnabled'] ?? true,
    mq4AlarmThresh: (j['mq4AlarmThresh'] ?? 2.2).toDouble(),
    calibRPM: (j['calibRPM'] as List?)?.map((e) => (e ?? 0) as int).toList() ?? List.filled(9, 0),
    filterAlert: j['filterAlert'] ?? false,
  );
}

class ApiService {
  ApiService(this.baseUrl);
  String baseUrl;

  Future<DeviceState?> fetchState() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/state')).timeout(const Duration(seconds: 2));
      if (r.statusCode == 200) return DeviceState.fromJson(jsonDecode(r.body));
    } catch (_) {}
    return null;
  }

  Future<bool> sendCommand(Map<String, dynamic> body) async {
    try {
      final r = await http.post(Uri.parse('$baseUrl/command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 3));
      return r.statusCode == 200;
    } catch (_) { return false; }
  }

  Future<bool> testConnection() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/state')).timeout(const Duration(seconds: 2));
      return r.statusCode == 200;
    } catch(_){ return false; }
  }
}

// ===== Home =====
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.i18n, required this.onThemeChanged, required this.onLanguageChanged});
  final I18n i18n;
  final void Function(ThemeMode) onThemeChanged;
  final void Function(String) onLanguageChanged;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _PlanItem {
  bool enabled;
  TimeOfDay start;
  TimeOfDay end;
  int mode;        // 0..5
  int fanPercent;  // kept for FW: we auto-fill from mode
  bool lightOn;
  bool ionOn;
  bool rgbOn;      // NEW

  _PlanItem({
    required this.enabled,
    required this.start,
    required this.end,
    required this.mode,
    required this.fanPercent,
    required this.lightOn,
    required this.ionOn,
    required this.rgbOn,
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'startMin': start.hour * 60 + start.minute,
      'endMin':   end.hour * 60 + end.minute,
      'mode': mode,
      'fanPercent': _pctForMode(mode),
      'lightOn': lightOn,
      'ionOn': ionOn,
      'rgbOn': rgbOn, // NEW
    };
  }

  static _PlanItem fromJson(Map<String, dynamic> j) => _PlanItem(
    enabled: j['enabled'] ?? true,
    start: _minToTod((j['startMin'] ?? 0) as int),
    end:   _minToTod((j['endMin']   ?? 0) as int),
    mode:  (j['mode'] ?? 1) as int,
    fanPercent: _pctForMode((j['mode'] ?? 1) as int),
    lightOn: (j['lightOn'] ?? false) as bool,
    ionOn:   (j['ionOn']   ?? false) as bool,
    rgbOn:   (j['rgbOn']   ?? false) as bool, // NEW
  );

  static TimeOfDay _minToTod(int m) => TimeOfDay(hour: (m ~/ 60) % 24, minute: m % 60);
  static int _pctForMode(int mode) {
    switch (mode) { case 0:return 20; case 1:return 35; case 2:return 50; case 3:return 65; case 4:return 100; default:return 35; }
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late ApiService api;
  DeviceState? state;
  Timer? _poller;
  String baseUrl = 'http://192.168.1.50';
  int _tab = 0;
  bool connected = false;
  List<_PlanItem> _plans = [];
  late TextEditingController _urlCtl;

  // UI state
  bool _rgbExpanded = false; // RGB paleti aç/kapa

  // helper: default pct by mode
  int _pctForMode(int mode) {
    switch (mode) { case 0:return 20; case 1:return 35; case 2:return 50; case 3:return 65; case 4:return 100; default:return (state?.fanPercent ?? 35); }
  }

  void _addPlan() async {
    final created = await showModalBottomSheet<_PlanItem>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _PlanEditor(i18n: widget.i18n),
    );
    if (created != null) {
      setState(() => _plans.add(created));
      _savePlansToDevice();
    }
  }

  Future<void> _savePlansToDevice() async {
    final body = { 'plans': _plans.map((e)=> e.toJson()).toList() };
    await _send(body);
  }

  Future<void> _syncTimeFromPhone() async {
    final epoch = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    const tzTR = 'EET-2EEST,M3.5.0/3,M10.5.0/4';
    await _send({'setTimeEpoch': epoch, 'tz': tzTR});
  }

  String? lastFilterMsg;

  @override
  void initState() {
    super.initState();
    _urlCtl = TextEditingController(text: baseUrl);
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    final p = await SharedPreferences.getInstance();
    baseUrl = p.getString('baseUrl') ?? baseUrl;
    api = ApiService(baseUrl);
    _urlCtl.text = baseUrl;
    final st = await api.fetchState();
    if (st != null) {
      try {
        final r = await http.get(Uri.parse('$baseUrl/state')).timeout(const Duration(seconds: 2));
        if (r.statusCode == 200) {
          final j = jsonDecode(r.body);
          final arr = (j['plans'] as List?) ?? [];
          _plans = arr.map((e)=> _PlanItem.fromJson(e as Map<String,dynamic>)).toList();
          setState(()=> state = DeviceState.fromJson(j));
        }
      } catch (_) {}
    }
    lastFilterMsg = p.getString('filterMsg');
    _startPolling();
  }

  void _startPolling() {
    _poller?.cancel();
    _poller = Timer.periodic(const Duration(seconds: 2), (_) async {
      final ok = await api.testConnection();
      if (mounted) setState(()=> connected = ok);
      if (!ok) return;
      final s = await api.fetchState();
      if (s!=null && mounted) setState(()=> state = s);
    });
  }

  @override
  void dispose() {
    _poller?.cancel();
    _urlCtl.dispose();
    super.dispose();
  }

  I18n get t => widget.i18n;
  
  double _toggleFontSize() {
  final labels = [ t.t('power'), t.t('light'), t.t('clean'), t.t('ion'), t.t('flame') ];
  int longest = 0;
  for (final label in labels) {
    final parts = label.split(RegExp(r'[\s/]+'));
    for (final p in parts) {
      if (p.length > longest) longest = p.length;
    }
  }
  if (longest >= 12) return 13;
  if (longest >= 10) return 14;
  if (longest >= 8)  return 15;
  return 16;
}

bool get _isMasterOn => state?.masterOn ?? true;
bool get _isActive   => connected && _isMasterOn;

/// Bölümü pasifleştirir (tıklama kilit + gri görünüm)
Widget _guard({required bool enabled, required Widget child}) {
  return IgnorePointer(
    ignoring: !enabled,
    child: Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: child,
    ),
  );
}

// --- Small helpers for UI
Widget _dot(Color c) =>
    Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

/// Tek kelimeler: tek satır, sabit font; taşarsa üç nokta YOK (clip).
/// İki kelimeyse: ikinci kelimeyi alt satıra at (max 2 satır), üç nokta YOK.
Widget _toggleTile(String title, bool value, ValueChanged<bool>? onChanged) {
  final parts = title.trim().split(RegExp(r'\s+'));
  final bool hasSpace = parts.length >= 2;
  final String twoLineTitle =
      hasSpace ? '${parts.first}\n${parts.skip(1).join(' ')}' : title;

  return Card(
    child: ListTile(
      dense: true,
      // istersen satırlar arası daha sıkı görünüm için:
      visualDensity: VisualDensity.compact,
      title: Text(
        twoLineTitle,
        maxLines: hasSpace ? 2 : 1,
        softWrap: hasSpace,
        overflow: TextOverflow.clip, // '...' asla yapma
        style: TextStyle(fontSize: _toggleFontSize()),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    ),
  );
}

  Widget _modePanel(DeviceState? s) {
    final items = [
      {'i':5, 'label': t.t('auto')},
      {'i':4, 'label': t.t('turbo')},
      {'i':3, 'label': t.t('high')},
      {'i':2, 'label': t.t('med')},
      {'i':1, 'label': t.t('low')},
      {'i':0, 'label': t.t('sleep')},
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10), // kompakt padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.t('mode'), style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            ...items.map((m) {
              final idx = m['i'] as int;
              final selected = (s?.mode ?? 1) == idx;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4), // aralık azaltıldı
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    visualDensity: VisualDensity.standard,
                    textStyle: TextStyle(fontSize: _toggleFontSize(), fontWeight: FontWeight.w600),
                    backgroundColor: selected ? null : Theme.of(context).colorScheme.surface,
                  ),
                  onPressed: connected ? () {
                    if (idx == 5) {
                      _send({'mode': idx});
                    } else {
                      _send({'mode': idx, 'fanPercent': _pctForMode(idx)});
                    }
                  } : null,
                  child: Text(m['label'] as String),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Collapsible & compact RGB swatch palette
  Widget _rgbPalette(DeviceState? s) {
    final current = Color.fromARGB(255, s?.r ?? 0, s?.g ?? 0, s?.b ?? 0);
    final int currentBr = s?.rgbBrightness ?? 100;
    final bool rgbEnabled = connected && (s?.rgbOn ?? false) && (s?.masterOn ?? true);
    final swatches = <Color>[
      Colors.white, const Color(0xFFFFE6CC),
      Colors.red, Colors.orange, Colors.amber, Colors.yellow,
      Colors.lime, Colors.green, Colors.teal, Colors.cyan,
      Colors.blue, Colors.indigo, Colors.purple, Colors.pink,
    ];

    Widget dot(Color c, {bool selected=false}) => Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: c, shape: BoxShape.circle,
        border: Border.all(
          color: selected ? Theme.of(context).colorScheme.primary : Colors.black12,
          width: selected ? 2 : 1,
        ),
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: ExpansionTile(
          initiallyExpanded: _rgbExpanded,
          onExpansionChanged: (v) => setState(() => _rgbExpanded = v),
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: Row(
            children: [
              dot(current, selected: true),
              const SizedBox(width: 10),
              Text(t.t('flame'), style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('R:${current.red} G:${current.green} B:${current.blue}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          children: [
            const SizedBox(height: 6),
            IgnorePointer(
              ignoring: !rgbEnabled,
              child: Opacity(
                opacity: rgbEnabled ? 1.0 : 0.35,
                child: Column(
                  children: [
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: swatches.map((c) {
                        final isSel = (c.red == current.red && c.green == current.green && c.blue == current.blue);
                        return InkWell(
                          onTap: connected ? () => _send({'rgb': {'r': c.red, 'g': c.green, 'b': c.blue}}) : null,
                          child: dot(c, selected: isSel),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.light_mode_outlined, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Slider(
                              value: currentBr.toDouble(),
                              min: 0, max: 100, divisions: 20,
                              label: '${currentBr.round()}%',
                              onChanged: connected ? (v) {} : null,
                              onChangeEnd: connected ? (v) => _send({'rgb': {'brightness': v.round()}}) : null,
                            ),
                          ),
                          Text('${currentBr.round()}%'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('3000K'),
                          avatar: const CircleAvatar(backgroundColor: Color.fromARGB(255, 255, 180, 107)),
                          onPressed: connected ? () => _send({'rgb': {'r':255,'g':180,'b':107}}) : null,
                        ),
                        ActionChip(
                          label: const Text('4000K'),
                          avatar: const CircleAvatar(backgroundColor: Color.fromARGB(255, 255, 209, 163)),
                          onPressed: connected ? () => _send({'rgb': {'r':255,'g':209,'b':163}}) : null,
                        ),
                        ActionChip(
                          label: const Text('5000K'),
                          avatar: const CircleAvatar(backgroundColor: Color.fromARGB(255, 255, 228, 206)),
                          onPressed: connected ? () => _send({'rgb': {'r':255,'g':228,'b':206}}) : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = state;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text(t.t('title')),
          const SizedBox(width: 8),
          _dot(connected ? Colors.green : Colors.red),
        ]),
        actions: [
          IconButton(
            tooltip: t.t('refresh'),
            onPressed: () async {
              final ok = await api.testConnection();
              if (mounted) setState(()=> connected = ok);
              if (!ok) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.t('reachable_no'))));
                return;
              }
              final st = await api.fetchState();
              if (st!=null) setState(()=> state = st);
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          _buildDashboard(),
          _buildSensors(),
          _buildPlanner(),
          _buildSettings(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i)=> setState(()=> _tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), label: t.t('home')),
          NavigationDestination(icon: const Icon(Icons.sensors), label: t.t('sensors')),
          NavigationDestination(icon: const Icon(Icons.schedule), label: t.t('planner')),
          NavigationDestination(icon: const Icon(Icons.settings), label: t.t('settings')),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
  final s = state;
  return SingleChildScrollView(
    padding: const EdgeInsets.all(14),
    child: Column(
      children: [
        if (!connected)
          Card(
            color: Colors.amber.withOpacity(0.2),
            child: const ListTile(
              leading: Icon(Icons.wifi_off),
              title: Text('Cihaz erişilemiyor'),
              subtitle: Text('Ayarlar’dan Base URL girin ve ESP32 ile aynı ağda olun.'),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sol
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Power kartı
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.filledTonal(
                            iconSize: 44,
                            onPressed: connected
                                ? () {
                                    final v = !(s?.masterOn ?? true);
                                    _send({'masterOn': v});
                                  }
                                : null,
                            icon: Icon(
                              Icons.power_settings_new_rounded,
                              color: (s?.masterOn ?? true)
                                  ? Colors.redAccent
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(t.t('power')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Power dışındaki anahtarları kilitle
                  _guard(
                    enabled: _isActive,
                    child: Column(
                      children: [
                        _toggleTile(
                          t.t('light'),
                          s?.lightOn ?? false,
                          _isActive ? (v) => _send({'lightOn': v}) : null,
                        ),
                        _toggleTile(
                          t.t('clean'),
                          s?.cleanOn ?? false,
                          _isActive ? (v) => _send({'cleanOn': v}) : null,
                        ),
                        _toggleTile(
                          t.t('ion'),
                          s?.ionOn ?? false,
                          _isActive ? (v) => _send({'ionOn': v}) : null,
                        ),
                        _toggleTile(
                          t.t('flame'),
                          s?.rgbOn ?? false,
                          _isActive ? (v) => _send({'rgb': {'on': v}}) : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            // Sağ: Mod paneli (kilitli olabilir)
            Expanded(
              flex: 1,
              child: _guard(
                enabled: _isActive,
                child: _modePanel(s),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // RGB paleti de master + connection’a bağlı
        _guard(enabled: _isActive, child: _rgbPalette(s)),

        const SizedBox(height: 10),

        // Alt: Temp & Humidity
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.t('temp')),
                      const SizedBox(height: 4),
                      Text(
                        (s?.tempC == null) ? '--' : '${s!.tempC.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.t('hum')),
                      const SizedBox(height: 4),
                      Text(
                        (s?.hum == null) ? '--' : '${s!.hum.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildSensors() {
    final s = state;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width>700 ? 3 : 2,
        crossAxisSpacing: 12, mainAxisSpacing: 12,
        children: [
          _stat(t.t('rpm'), (s?.rpm ?? 0).toDouble(), decimals: 0),
          _stat(t.t('pm'), s?.pm),
          _stat(t.t('mq4'), s?.mq4V),
          _stat(t.t('temp'), s?.tempC),
          _stat(t.t('hum'), s?.hum),
        ],
      ),
    );
  }

  Widget _stat(String title, double? v, {int decimals = 2}) {
    return Card(
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(title),
          const SizedBox(height:8),
          Text(
            v==null ? '--' : (decimals==0 ? v.toStringAsFixed(0) : v.toStringAsFixed(decimals)),
            style: const TextStyle(fontSize:22,fontWeight: FontWeight.bold),
          ),
        ]),
      ),
    );
  }

  Widget _buildPlanner() {
    final s = state;
    final hasAlert = (s?.filterAlert ?? false) || (lastFilterMsg == 'BAD');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(widget.i18n.t('planner'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              IconButton(
                tooltip: widget.i18n.t('refresh'),
                onPressed: () async {
                  final st = await api.fetchState();
                  if (st != null && mounted) setState(() => state = st);
                },
                icon: const Icon(Icons.refresh),
              ),
              TextButton.icon(
                onPressed: _syncTimeFromPhone,
                icon: const Icon(Icons.access_time_filled),
                label: Text(widget.i18n.t('sync_time')),
              ),
              FilledButton.icon(
                onPressed: _addPlan,
                icon: const Icon(Icons.add),
                label: Text(widget.i18n.t('add_plan')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (hasAlert)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded),
                title: Text(widget.i18n.t('filter_alert_title')),
                subtitle: Text(widget.i18n.t('filter_alert_subtitle')),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _plans.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event_busy, size: 64),
                        const SizedBox(height: 12),
                        Text(widget.i18n.t('no_plan')),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _plans.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _plans[index];
                      final timeText = _fmtTod(item.start) + ' – ' + _fmtTod(item.end);
                      final modeNames = [t.t('sleep'), t.t('low'), t.t('med'), t.t('high'), t.t('turbo'), t.t('auto')];

                      final base = item.mode == 5
                          ? modeNames[item.mode]
                          : '${modeNames[item.mode]}  %${_pctForMode(item.mode)}';

                      final extras = [
                        if (item.lightOn) '💡',
                        if (item.ionOn) '🧪',
                        if (item.rgbOn) '🔥',
                      ].join(' ');
                      final subtitle = extras.isEmpty ? base : '$base  $extras';

                      return Card(
                        child: ListTile(
                          leading: Switch(
                            value: item.enabled,
                            onChanged: (v){ setState(()=> item.enabled = v); _savePlansToDevice(); },
                          ),
                          title: Text(timeText),
                          subtitle: Text(subtitle),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final edited = await showModalBottomSheet<_PlanItem>(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (ctx) => _PlanEditor(i18n: widget.i18n, initial: item),
                                  );
                                  if (edited != null) {
                                    setState(()=> _plans[index] = edited);
                                    _savePlansToDevice();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: (){ setState(()=> _plans.removeAt(index)); _savePlansToDevice(); },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _fmtTod(TimeOfDay t){
    String two(int x)=> x.toString().padLeft(2,'0');
    return '${two(t.hour)}:${two(t.minute)}';
  }

  Widget _buildSettings() {
    final s = state;
    final mq4Ctl = TextEditingController(text: (s?.mq4AlarmThresh ?? 2.2).toStringAsFixed(2));
    final redWarn = (s?.filterAlert ?? false) || (lastFilterMsg == 'BAD');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text(t.t('base_url'), style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height:8),
                Row(children:[
                  Expanded(child: TextField(controller: _urlCtl, enableSuggestions: false, autocorrect: false,)),
                  const SizedBox(width:8),
                  FilledButton(
                    onPressed: () async {
                      baseUrl = _urlCtl.text.trim();
                      api.baseUrl = baseUrl;
                      final p = await SharedPreferences.getInstance();
                      await p.setString('baseUrl', baseUrl);
                      _startPolling();
                    },
                    child: Text(t.t('save')),
                  ),
                  const SizedBox(width:8),
                  OutlinedButton(
                    onPressed: () async {
                      final ok = await api.testConnection();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? t.t('reachable_yes') : t.t('reachable_no'))),
                      );
                      setState(()=> connected = ok);
                    },
                    child: Text(t.t('test')),
                  ),
                ]),
                const SizedBox(height:4),
                Text(t.t('base_url_hint'), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(height:12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.t('mq4_alarm'), style: const TextStyle(fontWeight: FontWeight.w600)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.t('enable_mq4')),
                value: s?.mq4AlarmEnabled ?? true,
                onChanged: connected ? (v)=> _send({'mq4AlarmEnabled': v}) : null,
              ),
              Row(children:[
                Text('${t.t('threshold')}: '),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: mq4Ctl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width:8),
                FilledButton(
                  onPressed: connected ? (){
                    final val = double.tryParse(mq4Ctl.text.trim());
                    if (val != null) _send({'mq4AlarmThresh': val});
                  } : null,
                  child: Text(t.t('run')),
                ),
              ]),
            ]),
          ),
        ),
        const SizedBox(height:12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.t('filter_care'), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height:8),
              Wrap(spacing:8, children: [
                FilledButton.icon(
                  onPressed: connected ? _runCalibration : null,
                  icon: const Icon(Icons.tune), label: Text(t.t('calibrate')),
                ),
                FilledButton.tonalIcon(
                  onPressed: connected ? _runTest : null,
                  icon: const Icon(Icons.fact_check), label: Text(t.t('test_run')),
                ),
              ]),
              const SizedBox(height:8),
              if (redWarn)
                Text(t.t('red_warning'),
                  style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
        const SizedBox(height:12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Text('${t.t('theme')}: '), const SizedBox(width:8),
              DropdownButton<ThemeMode>(
                value: Theme.of(context).brightness==Brightness.dark ? ThemeMode.dark : ThemeMode.light,
                items: [
                  DropdownMenuItem(value: ThemeMode.light, child: Text(t.t('theme_light'))),
                  DropdownMenuItem(value: ThemeMode.dark,  child: Text(t.t('theme_dark'))),
                ],
                onChanged: (m){ if (m!=null) widget.onThemeChanged(m); },
              ),
              const Spacer(),
              Text('${t.t('language')}: '), const SizedBox(width:8),
              DropdownButton<String>(
                value: widget.i18n.code,
                items: I18n.supported.entries.map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                )).toList(),
                onChanged: (loc) {
                  if (loc != null) {
                    widget.onLanguageChanged(loc);
                    SharedPreferences.getInstance().then((p) => p.setString('lang', loc));
                  }
                },
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  // ===== Calibration & Test =====
  Future<void> _runCalibration() async {
    _showSnack(widget.i18n.t('calibrating'));
    await _send({'mode': 1});
    final steps = [20,30,40,50,60,70,80,90,100];
    final results = <int>[];
    for (final p in steps) {
      await _send({'fanPercent': p});
      final rpm = await _waitStableRPM();
      results.add(rpm);
    }
    await api.sendCommand({'calibSave': results});
    final st = await api.fetchState();
    if (st!=null) setState(()=> state = st);
    _showSnack(widget.i18n.t('ok'));
  }

  Future<void> _runTest() async {
    _showSnack(widget.i18n.t('testing'));
    await _send({'mode': 1});
    const p = 50;
    await _send({'fanPercent': p});
    final cur = await _waitStableRPM();
    final s = state;
    if (s == null || s.calibRPM.length != 9) return;
    final ref = s.calibRPM[3];
    String msg = 'OK';
    if (ref > 0) {
      final drop = 1 - (cur / ref.toDouble());
      if (drop >= 0.20) msg = 'BAD';
    }
    final sp = await SharedPreferences.getInstance();
    await sp.setString('filterMsg', msg);
    setState(()=> lastFilterMsg = msg);
    _showSnack(msg == 'BAD' ? widget.i18n.t('filter_bad') : widget.i18n.t('filter_ok'));
  }

  Future<int> _waitStableRPM() async {
    final samples = <int>[];
    final end = DateTime.now().isUtc
        ? DateTime.now().toUtc().add(const Duration(seconds: 8))
        : DateTime.now().add(const Duration(seconds: 8));
    while (DateTime.now().isBefore(end)) {
      final s = await api.fetchState();
      if (mounted && s != null) setState(()=> state = s);
      if (s?.rpm != null) {
        samples.add(s!.rpm);
        if (samples.length >= 3) {
          final a = samples[samples.length-3].toDouble();
          final b = samples[samples.length-2].toDouble();
          final c = samples[samples.length-1].toDouble();
          final avg = (a+b+c)/3.0;
          final ok = ( ( (a-avg).abs()/avg < 0.03 ) &&
                       ( (b-avg).abs()/avg < 0.03 ) &&
                       ( (c-avg).abs()/avg < 0.03 ) );
          if (ok) return avg.round();
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    return samples.isNotEmpty ? samples.last : 0;
  }

  // ===== Helpers =====
  Future<void> _send(Map<String,dynamic> body) async {
    if (!connected) { _showSnack(t.t('device_not')); return; }
    final ok = await api.sendCommand(body);
    if (!ok) _showSnack(t.t('command_failed'));
    final s = await api.fetchState();
    if (s!=null) setState(()=> state = s);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ===== Plan Editor =====
class _PlanEditor extends StatefulWidget {
  const _PlanEditor({required this.i18n, this.initial});
  final I18n i18n;
  final _PlanItem? initial;
  @override
  State<_PlanEditor> createState() => _PlanEditorState();
}

class _PlanEditorState extends State<_PlanEditor> {
  late bool enabled;
  late TimeOfDay start;
  late TimeOfDay end;
  int mode = 1;
  bool lightOn = false;
  bool ionOn   = false;
  bool rgbOn   = false; // NEW

  int _pctForMode(int m){
    switch (m) { case 0:return 20; case 1:return 35; case 2:return 50; case 3:return 65; case 4:return 100; default:return 35; }
  }

  @override
  void initState(){
    super.initState();
    final i = widget.initial;
    enabled = i?.enabled ?? true;
    start   = i?.start   ?? const TimeOfDay(hour: 8, minute: 0);
    end     = i?.end     ?? const TimeOfDay(hour: 9, minute: 0);
    mode    = i?.mode    ?? 1;
    lightOn = i?.lightOn ?? false;
    ionOn   = i?.ionOn   ?? false;
    rgbOn   = i?.rgbOn ?? false;
  }

  Future<TimeOfDay?> _pick(TimeOfDay v) async {
    return showTimePicker(
      context: context, initialTime: v,
      builder: (ctx, child)=> MediaQuery(data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modeNames = [widget.i18n.t('sleep'), widget.i18n.t('low'), widget.i18n.t('med'),
      widget.i18n.t('high'), widget.i18n.t('turbo'), widget.i18n.t('auto')];

    final pctInfo = mode == 5 ? '' : '  %${_pctForMode(mode)}';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children:[
              const Icon(Icons.schedule), const SizedBox(width:8), Text(widget.i18n.t('planner')), const Spacer(),
              Switch(value: enabled, onChanged: (v)=> setState(()=> enabled = v)),
            ]),
            const SizedBox(height:12),
            Row(children:[
              Expanded(child: _timeField(widget.i18n.t('start'), start, () { _pick(start).then((p){ if (p!=null) setState(()=> start = p); }); })),
              Expanded(child: _timeField(widget.i18n.t('end'), end, () { _pick(end).then((p){ if (p!=null) setState(()=> end = p); }); })),
            ]),
            const SizedBox(height:12),
            DropdownButtonFormField<int>(
              value: mode,
              items: List.generate(6, (i)=> DropdownMenuItem(value:i, child: Text(modeNames[i]))),
              onChanged: (v){ setState(()=> mode = v ?? 1); },
              decoration: InputDecoration(labelText: widget.i18n.t('mode')),
            ),
            if (mode != 5) Padding(
              padding: const EdgeInsets.only(top:8.0),
              child: Text('${widget.i18n.t('plan_speed')}$pctInfo'),
            ),
            const SizedBox(height:12),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:12, vertical:8),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(widget.i18n.t('light')),
                      value: lightOn,
                      onChanged: (v)=> setState(()=> lightOn = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(widget.i18n.t('ion')),
                      value: ionOn,
                      onChanged: (v)=> setState(()=> ionOn = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(widget.i18n.t('flame')),
                      value: rgbOn,
                      onChanged: (v)=> setState(()=> rgbOn = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height:16),
            Row(children:[
              OutlinedButton(onPressed: ()=> Navigator.pop(context), child: Text(widget.i18n.t('cancel'))),
              const Spacer(),
              FilledButton(onPressed: (){
                Navigator.pop(context, _PlanItem(
                  enabled: enabled,
                  start: start,
                  end: end,
                  mode: mode,
                  fanPercent: _pctForMode(mode),
                  lightOn: lightOn,
                  ionOn: ionOn,
                  rgbOn: rgbOn,
                ));
              }, child: Text(widget.i18n.t('save'))),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _timeField(String label, TimeOfDay v, VoidCallback onTap){
    String two(int x) => x.toString().padLeft(2, '0');
    return TextFormField(
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(labelText: label),
      controller: TextEditingController(text: '${two(v.hour)}:${two(v.minute)}'),
    );
  }
}
