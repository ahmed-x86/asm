
# بيئة تطوير الأسمبلي 🚀

![Windows 10](https://img.shields.io/badge/Windows_10-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Windows 11](https://img.shields.io/badge/Windows_11-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Windows 7](https://img.shields.io/badge/Windows_7-0078D6?style=for-the-badge&logo=windows&logoColor=white)

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Manjaro](https://img.shields.io/badge/Manjaro-35BF5C?style=for-the-badge&logo=manjaro&logoColor=white)
![CachyOS](https://img.shields.io/badge/CachyOS-0080FF?style=for-the-badge&logo=arch-linux&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E9433F?style=for-the-badge&logo=ubuntu&logoColor=white)
![Linux Mint](https://img.shields.io/badge/Linux_Mint-87CF3E?style=for-the-badge&logo=linux-mint&logoColor=white)
![ZorinOS](https://img.shields.io/badge/Zorin_OS-0CC0DF?style=for-the-badge&logo=zorin-os&logoColor=white)
![Fedora](https://img.shields.io/badge/Fedora-51A2DA?style=for-the-badge&logo=fedora&logoColor=white)
![Nobara](https://img.shields.io/badge/Nobara-750000?style=for-the-badge&logo=fedora&logoColor=white)
![Kali Linux](https://img.shields.io/badge/Kali_Linux-557CF2?style=for-the-badge&logo=kali-linux&logoColor=white)
![Parrot OS](https://img.shields.io/badge/Parrot_OS-36C5CC?style=for-the-badge&logo=parrot-security&logoColor=white)
![Gentoo](https://img.shields.io/badge/Gentoo-54487A?style=for-the-badge&logo=gentoo&logoColor=white)
![Void Linux](https://img.shields.io/badge/Void_Linux-47841F?style=for-the-badge&logo=void-linux&logoColor=white)
![VS Code](https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=visual-studio-code&logoColor=white)
![Bazzit](https://img.shields.io/badge/Bazzit-525865?style=for-the-badge&logo=fedora&logoColor=white)
![Peppermint](https://img.shields.io/badge/Peppermint_OS-E11221?style=for-the-badge&logo=peppermint&logoColor=white)
![Puppy Linux](https://img.shields.io/badge/Puppy_Linux-B22222?style=for-the-badge&logo=linux&logoColor=white)
![openSUSE](https://img.shields.io/badge/openSUSE-73BA48?style=for-the-badge&logo=opensuse&logoColor=white)
![Alpine Linux](https://img.shields.io/badge/Alpine_Linux-0D597F?style=for-the-badge&logo=alpine-linux&logoColor=white)


### مستودع شامل مصمم لإطلاق شرارة تطوير الأسمبلي (ASM) الخاصة بك. توفر هذه البيئة دعماً جاهزاً للاستخدام لأنظمة Linux x64 و Windows (x86/x64)، وتتميز بإعدادات VS Code مجهزة مسبقاً لسير عمل سلس.

-----

## 🛠️ التثبيت السريع

اختر سلاحك (نظام التشغيل) وشغل الأمر المناسب لإعداد بيئتك فوراً:

## 🐧 لينكس (تثبيت بسطر أوامر واحد)

يدعم Arch، Debian/Ubuntu، Fedora، Alpine، openSUSE، Solus، Gentoo، Puppy Linux، و Void.

```bash
bash <(curl -sSL https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-linux.sh)
```

### 🪟 ويندوز 10 / 11 (تثبيت عبر PowerShell)

مُحسن لبيئات ويندوز الحديثة.

```powershell
irm https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-windows.ps1 | iex
```

### 🏛️ ويندوز 7 (دعم الأنظمة القديمة)

سكربت مخصص لدعم التوافق مع ويندوز 7.

```powershell
irm https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-windows7.ps1 | iex
```

-----

## 🏗️ التثبيت اليدوي (محلياً)

إذا كنت تفضل استنساخ المستودع (Clone) وتشغيل السكربتات محلياً:

**للينكس:**

```bash
git clone https://github.com/ahmed-x86/asm.git
cd asm
chmod +x install-linux.sh
./install-linux.sh

```

**للويندوز (جميع الإصدارات):**

```powershell
git clone https://github.com/ahmed-x86/asm.git
cd asm
# لويندوز 10/11:
.\install-windows.ps1
# لويندوز 7:
.\install-windows7.ps1
```

-----

## ✨ الميزات الأساسية

  * **دعم مزدوج للمنصات:** مثبتات أصلية (Native) لكل من ويندوز ولينكس، مما يضمن اتساق بيئة التطوير الخاصة بك في كل مكان.
  * **تكامل مع VS Code:** ملفات `tasks.json` و `launch.json` مجهزة مسبقاً لتسمح لك ببناء وعمل Debug للكود باختصار واحد (`Ctrl+Shift+B`).
  * **أداة سطر أوامر عامة (Global CLI):** يثبت أمر `asm-run` المخصص على مستوى النظام، مما يتيح لك تجميع (Compile) واختبار ملفات `.asm` مباشرة من أي تيرمينال بدون فتح محرر أكواد.
  * **إدارة ذكية للاعتماديات:**
      * **على لينكس:** يكتشف مدير الحزم الخاص بك تلقائياً (`pacman`, `apt`, `dnf`, `xbps`, `emerge`, `zypper`, `apk`, `pkg`)، ويتحقق من الحزم الموجودة لتخطي التحميلات غير الضرورية، ويثبت الأدوات المطلوبة (`NASM`, `GCC`, `Wine`, `UASM`).
      * **على ويندوز:** يجهز NASM وأدوات البناء المطلوبة تلقائياً.
  * **دعم الأنظمة القديمة:** مثبت خاص لـ **ويندوز 7** لضمان أن تطوير الأسمبلي ليس مقيداً بإصدار نظام التشغيل.
  * **تجميع متقاطع (Cross-Compilation):** سلاسل أدوات (Toolchains) جاهزة للاستخدام لتجميع واختبار ملفات ويندوز التنفيذية مباشرة من لينكس باستخدام Wine و MinGW.

## 🧠 ميزات المحرك الذكي

  * **تنفيذ مضاد للرصاص (Bulletproof):** يتميز بفحوصات مدمجة لاستقرار الشبكة، وحلقات صارمة للتحقق من صحة الإدخالات (مضادة للأخطاء البشرية)، وفخ لـ `Ctrl+C` ينظف التحميلات الجزئية تلقائياً في حالة المقاطعة.
  * **الأمان أولاً:** يطبق **فحوصات سلامة SHA256** صارمة للملفات التنفيذية الخارجية (uasm, Irvine library) لضمان أصالة الملفات ومنع عمليات فك الضغط التالفة.
  * **مستقل عن المحرر (Editor Agnostic):** يفحص ويكتشف تلقائياً بيئة التطوير المتثبتة عندك (**VS Code، VSCodium، Cursor، Trae، Windsurf، أو Google Antigravity**) ويثبت إضافات الأسمبلي (Syntax Highlighting و Error Lens).
  * **تتبع شامل للحزم:** يكتشف ما إذا كان المحرر الخاص بك مثبتاً عبر **مدير الحزم الأصلي، أو Snap، أو Flatpak** ويقوم بإعداد الإضافات باستخدام الأوامر المعزولة الصحيحة.
  * **تحديث تلقائي للمسارات:** يُحدث `launch.json` و `tasks.json` ديناميكياً بناءً على اسم المستخدم الحالي لنظام التشغيل ومسار المجلد. لا يتطلب أي تعديل يدوي\!
  * **التوافق مع Alpine:** يتضمن خطوة استباقية مخصصة لإصلاح توافق `sed` على Alpine Linux.

-----

## 🎭 ملاحظة ختامية

> [\!IMPORTANT]
> تم بناء هذا المشروع لإثبات أن "فهم لينكس" ليس مجرد كلام، بل هو بناء حلول تعمل على **9+ توزيعات** بنقرة واحدة.

  - `echo -e "\033[1;35m فيه حمار قال اني مابفهمش لينكس.. عايز اقولك شوف السكربت ده يا حمار بشري\033[0m"`

**ابقى قوياً، واصل البرمجة. 🚀**

> **ملاحظة لمستخدمي Arch:** لأن جملة "I use Arch btw" مش المفروض يكون معناها إنك تضيع 3 ساعات في الإعدادات. إحنا مظبطينك. 😎

-----

# i use arch btw

-----