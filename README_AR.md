# بيئة تطوير لغة التجميع 🚀

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


مستودع شامل مصمم لتسهيل بدء تطوير تطبيقات لغة التجميع (ASM) على نظام لينكس. توفر هذه البيئة دعمًا فوريًا لأنظمة لينكس x64 وويندوز (32/64 بت)، مع إعدادات مُعدة مسبقًا في VS Code لضمان سير عمل سلس.


مستودع متكامل مصمم خصيصًا لبدء تطوير تطبيقاتك بلغة التجميع (ASM) على نظام لينكس. توفر هذه البيئة دعمًا جاهزًا لأنظمة لينكس x64 وويندوز (32/64 بت)، مع إعدادات VS Code مُعدة مسبقًا لضمان سير عمل سلس.


مستودع شامل مصمم لتسهيل بدء تطوير تطبيقاتك بلغة التجميع (ASM) على نظام لينكس. 🛠️ التثبيت

يمكنك إعداد بيئتك باستخدام إحدى الطريقتين التاليتين:

## 1. التثبيت عبر سطر واحد (عبر الإنترنت)

استخدم هذا الأمر لتكوين مجلدك الحالي مباشرةً دون الحاجة إلى استنساخ المستودع بالكامل:

```
bash <(curl -sSL https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-linux.sh)
```
## 2. الإعداد المحلي (يدويًا)

إذا كنت قد استنسخت المستودع مسبقًا أو تفضل التثبيت اليدوي:


```
git clone https://github.com/ahmed-x86/asm.git
cp -r asm/. .

chmod +x install-linux.sh
./install-linux.sh
```
## ✨ الميزات الرئيسية

الكشف الذكي عن التوزيعات: يكشف تلقائيًا عن التبعيات ويُثبّتها لأنظمة Arch Linux و Debian/Ubuntu و Fedora.

التكامل مع VS Code: ملفا tasks.json و launch.json مُعدان مسبقًا يسمحان لك ببناء وتشغيل التعليمات البرمجية الخاصة بك باستخدام اختصار واحد (Ctrl+Shift+B).

دعم متعدد المنصات: مجموعات أدوات جاهزة للاستخدام (NASM، MinGW-w64، Wine) لتجميع واختبار ملفات Windows الثنائية مباشرةً من طرفية Linux.

مُحسَّن لنظام Arch: لأن استخدام Arch لا يعني قضاء ثلاث ساعات في الإعدادات. 😎

## 💡 التحسينات المُضافة:

المصطلحات: تم تغيير "التثبيت المباشر" إلى "مثبّت سطر واحد"، وهو المصطلح الأكثر شيوعًا في أوساط DevOps.


الوضوح: تم توضيح أن تكامل VS Code يدعم كلاً من عملية البناء والتصحيح.

الأسلوب: تم ​​الحفاظ على روح الدعابة الخاصة بنظام "Arch Linux"، مع تحسين الشروحات التقنية لتكون أكثر رسمية.

---