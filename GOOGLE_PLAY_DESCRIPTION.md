# Google Play 등록정보 문안

Play Console에 **그대로 복사해 붙여 넣는** 문안이다. 로케일마다 독립된 섹션을
두고, 각 필드는 코드 블록 하나에 담았다.

## ⚠️ 붙여넣기 규칙

**한 필드에는 한 언어만 넣는다.**

이 파일의 이전 버전은 한 문서에 한국어·영어·스페인어 설명을 `---`로만
구분해 두었고, 그 결과 **ko-KR 자세한 설명 필드에 두 언어가 함께 들어가
라이브로 노출됐다.** 한국어 설명 뒤에 스페인어가 뭉개진 채 이어붙은 상태였다.

- Play Console의 로케일 선택기에서 **대상 언어를 먼저 고른다.**
- 그 로케일 섹션의 코드 블록 **하나만** 복사한다.
- 블록 경계 밖의 설명문(이 문서의 해설)은 절대 포함하지 않는다.
- 붙여넣은 뒤 필드 맨 아래까지 스크롤해 **다른 언어가 섞여 있지 않은지 확인한다.**

## 문안 작성 규칙

- **없는 기능은 쓰지 않는다.** 구현되지 않은 기능을 설명에 넣으면 Play 정책상
  등록이 거부될 수 있다. "곧 출시 예정" 표기도 쓰지 않는다.
- 과장하지 않는다. 앱 내 문구(`lib/services/app_localizations.dart`)와 톤을 맞춘다.
- 번역이 아니라 **로케일별로 쓴다.** 검색어는 언어마다 다르다.

## 현재 구현 기준 (문안의 사실 근거)

| 내용 | 근거 |
|---|---|
| 룰렛 25·30·45·50·60·90분 | `lib/models/duration_weights.dart:18` |
| 하루 2회, 자정 초기화 | `lib/services/spin_storage.dart:6` |
| 집중 후 10분 휴식 | `lib/services/timer_alert_service.dart` |
| 시작·종료 알림 **구현됨** | `flutter_local_notifications` |
| 세션 기록·캘린더 | `lib/pages/history_page.dart` |
| D-Day 목표 (무료) | `lib/services/dday_goal_service.dart` |
| 7일 집중 챌린지·배지 | `lib/models/focus_challenge.dart:21` |
| Pro 1회 구매 | `in_app_purchase`, `GOOGLE_PLAY_BILLING.md` |
| 지원 언어 ko·en·es·zh | `lib/models/app_language.dart:42` |
| 로컬 저장, 계정 없음 | `shared_preferences` |
| 광고 | `google_mobile_ads` |

개인정보 처리방침 URL (앱 내 링크와 동일, `lib/pages/settings_page.dart:262`):

```
https://docs.google.com/document/d/e/2PACX-1vShowtzVPBEdPtpYgWt0oFfhj0yz2BTL6Nb0n3NHavgb0giAcQA2TbT4nnL3mEk1ayjrLqHxf1egHqh/pub
```

지원 이메일: `jacobooh7307@gmail.com`

---

# ko-KR (한국어)

## 앱 이름 — 30자 제한

```
RandomFocus - 공부 집중 타이머
```

23자. 브랜드명은 LOOPET·Sobrita와 같이 로마자로 유지하고, 뒤에 검색어를 붙였다.
`공부 타이머`와 `집중 타이머`를 한 번에 받는다.

대안:

```
RandomFocus - 집중 타이머 공부 기록
```

## 간단한 설명 — 80자 제한

```
룰렛으로 공부 시간을 정하는 집중 타이머. 포모도로처럼 집중하고 쉬며, 기록으로 남깁니다.
```

## 자세한 설명 — 4000자 제한

```
룰렛을 돌려 공부 시간을 정하는 집중 타이머입니다.

타이머를 켜고 "몇 분 할까" 고민하다 시간을 보낸 적이 있다면, 그 결정을 룰렛에 맡겨 보세요. 포모도로처럼 집중과 휴식을 번갈아 하지만, 시간은 룰렛이 정합니다.


■ 룰렛으로 집중 시간 정하기

25분, 30분, 45분, 50분, 60분, 90분 중 하나가 무작위로 나옵니다. 룰렛은 하루 2회 돌릴 수 있고 자정에 초기화됩니다. 고민을 줄이고 바로 시작하기 위한 제한입니다.


■ 집중 타이머와 10분 휴식

원형 타이머로 남은 시간을 봅니다. 집중 시간이 끝나면 10분 휴식으로 이어지고, 시작과 종료 시점에 알림을 받습니다. 알림은 설정에서 끌 수 있습니다.


■ 집중 기록

완료한 세션과 중단한 세션이 모두 저장됩니다. 캘린더에서 날짜별로 확인하고, 이번 달과 오늘의 세션 수·집중 시간을 봅니다.


■ D-Day 목표

시험이나 마감처럼 집중해야 할 날을 정해두면 집중 화면에 D-Day가 함께 표시됩니다. 무료로 쓸 수 있습니다.


■ 7일 집중 챌린지

집중한 날을 7일 모으면 배지를 받습니다. 연속이 아니어도 됩니다.


■ 계정 없이 시작

회원가입이나 로그인이 없습니다. 세션 기록은 기기에 저장되고 개인정보는 수집하지 않습니다. 광고 표시를 위해 광고 ID를 사용합니다(Google Mobile Ads).


■ RandomFocus Pro (선택)

1회 구매로 광고를 없애고, 집중 시간과 각 시간이 나올 확률을 직접 정하고, 자주 쓰는 조합을 프리셋으로 저장할 수 있습니다. 구독이 아닙니다. 무료로도 룰렛, 타이머, 기록, D-Day를 모두 쓸 수 있습니다.


■ 4개 언어 지원

한국어, 영어, 스페인어, 중국어를 지원합니다. 기기 언어를 자동으로 따르거나 설정에서 직접 고를 수 있습니다.


시험 공부, 과제, 업무처럼 "일단 시작"이 어려운 일에 쓰기 좋습니다.


개인정보 처리방침: https://docs.google.com/document/d/e/2PACX-1vShowtzVPBEdPtpYgWt0oFfhj0yz2BTL6Nb0n3NHavgb0giAcQA2TbT4nnL3mEk1ayjrLqHxf1egHqh/pub
문의: jacobooh7307@gmail.com
```

## 새로운 기능 — 500자 제한

```
• 한국어를 지원합니다. 기기 언어를 따르거나 설정에서 직접 고를 수 있어요.
• 중요한 날까지 남은 일수를 세는 D-Day 목표를 추가했어요.
```

---

# en-US (English)

## App name — 30 char limit

```
RandomFocus - Study Timer
```

25 characters. Picks up both `study timer` and `focus timer`.

## Short description — 80 char limit

```
A focus timer that spins for your study length. Focus, break, and keep a record.
```

80 characters.

## Full description — 4000 char limit

```
A focus timer that picks your study length for you.

If you have ever burned time deciding how long to work, hand that decision to the wheel. RandomFocus alternates focus and breaks like a pomodoro timer, except the wheel chooses the length.


■ Spin for your focus time

You get one of 25, 30, 45, 50, 60 or 90 minutes at random. The wheel gives you 2 spins per day and resets at midnight. The limit is there to cut the deliberating and get you started.


■ Focus timer and a 10-minute break

A circular timer shows the time left. When focus ends a 10-minute break follows, and you get a notification at the start and end of each one. Notifications can be turned off in settings.


■ Your focus record

Every session is saved, whether you finished it or stopped early. Browse them by date in the calendar and see your session count and focused time for today and this month.


■ D-Day goal

Set the date you are working toward, like an exam or a deadline, and the countdown appears on your focus screen. Free to use.


■ 7-day focus challenge

Collect 7 focus days to earn the badge. They do not have to be consecutive.


■ Start without an account

No sign-up, no login. Your session history stays on your device and no personal information is collected. An advertising ID is used to show ads (Google Mobile Ads).


■ RandomFocus Pro (optional)

A one-time purchase removes ads, lets you choose your own durations and how often each one is drawn, and saves your favorite combinations as presets. Not a subscription. The wheel, timer, history and D-Day goal are all free.


■ Four languages

English, Korean, Spanish and Chinese. The app follows your device language, or you can pick one in settings.


Useful for exam prep, assignments and work — anything where starting is the hard part.


Privacy Policy: https://docs.google.com/document/d/e/2PACX-1vShowtzVPBEdPtpYgWt0oFfhj0yz2BTL6Nb0n3NHavgb0giAcQA2TbT4nnL3mEk1ayjrLqHxf1egHqh/pub
Support: jacobooh7307@gmail.com
```

## What's new — 500 char limit

```
• Korean is now supported. The app follows your device language, or pick one in settings.
• Added a D-Day goal that counts the days until a date that matters to you.
```

---

# es-419 (Español, Latinoamérica)

## Nombre de la app — límite 30 caracteres

```
RandomFocus - Temporizador
```

26 caracteres. `temporizador` es el término de búsqueda principal.

## Descripción breve — límite 80 caracteres

```
Temporizador de concentración: la rueda elige cuánto estudias y queda registrado.
```

80 caracteres.

## Descripción completa — límite 4000 caracteres

```
Un temporizador de concentración que elige por ti cuánto estudiar.

Si alguna vez perdiste tiempo decidiendo cuántos minutos trabajar, déjale esa decisión a la rueda. RandomFocus alterna concentración y descanso como un temporizador pomodoro, solo que la duración la elige la rueda.


■ Gira para elegir tu tiempo

Sale al azar uno de estos tiempos: 25, 30, 45, 50, 60 o 90 minutos. Tienes 2 giros por día y se reinician a medianoche. El límite existe para que dejes de deliberar y empieces.


■ Temporizador y descanso de 10 minutos

Un temporizador circular te muestra el tiempo restante. Al terminar la concentración sigue un descanso de 10 minutos, y recibes una notificación al inicio y al final de cada uno. Puedes desactivarlas en ajustes.


■ Tu registro de concentración

Cada sesión queda guardada, la termines o la detengas antes. Revísalas por fecha en el calendario y mira cuántas sesiones y cuánto tiempo acumulaste hoy y este mes.


■ Meta D-Day

Define la fecha hacia la que trabajas, como un examen o una entrega, y la cuenta regresiva aparece en tu pantalla de concentración. Es gratis.


■ Reto de 7 días

Reúne 7 días de concentración para ganar la insignia. No tienen que ser seguidos.


■ Empieza sin cuenta

Sin registro ni inicio de sesión. Tu historial se queda en tu dispositivo y no recopilamos información personal. Se usa un identificador de publicidad para mostrar anuncios (Google Mobile Ads).


■ RandomFocus Pro (opcional)

Una compra única quita los anuncios, te deja elegir tus propias duraciones y con qué frecuencia sale cada una, y guardar tus combinaciones favoritas como ajustes preestablecidos. No es una suscripción. La rueda, el temporizador, el historial y la meta D-Day son gratis.


■ Cuatro idiomas

Español, inglés, coreano y chino. La app sigue el idioma de tu dispositivo, o puedes elegirlo en ajustes.


Útil para preparar exámenes, tareas y trabajo: para todo aquello en que lo difícil es empezar.


Política de Privacidad: https://docs.google.com/document/d/e/2PACX-1vShowtzVPBEdPtpYgWt0oFfhj0yz2BTL6Nb0n3NHavgb0giAcQA2TbT4nnL3mEk1ayjrLqHxf1egHqh/pub
Soporte: jacobooh7307@gmail.com
```

## Novedades — límite 500 caracteres

```
• Ya está disponible en coreano. La app sigue el idioma de tu dispositivo, o puedes elegirlo en ajustes.
• Nueva meta D-Day: cuenta los días que faltan para una fecha importante.
```

---

# zh-CN (简体中文)

앱이 `zh`를 지원하는데 중국어 등록정보가 아직 없다. 아래 문안을 그대로 쓴다.

## 应用名称 — 限 30 字符

```
RandomFocus - 专注计时器
```

## 简短说明 — 限 80 字符

```
转动转盘决定学习时长的专注计时器。专注、休息、留下记录。
```

## 完整说明 — 限 4000 字符

```
一款帮你决定学习时长的专注计时器。

如果你曾经在"该学多久"上纠结到浪费时间，就把这个决定交给转盘。RandomFocus 像番茄钟一样交替专注与休息，只是时长由转盘决定。


■ 转动转盘决定专注时长

随机得到 25、30、45、50、60 或 90 分钟中的一个。转盘每天可转 2 次，午夜重置。这个限制是为了让你少纠结、早开始。


■ 专注计时与 10 分钟休息

圆形计时器显示剩余时间。专注结束后接 10 分钟休息，每段的开始和结束都会收到通知。通知可以在设置中关闭。


■ 专注记录

每次专注都会保存，无论完成还是提前停止。在日历中按日期查看，并了解今天和本月的专注次数与时长。


■ D-Day 目标

设定你要冲刺的日期，比如考试或截止日，倒计时就会显示在专注页面上。免费使用。


■ 7 日专注挑战

集齐 7 个专注日即可获得徽章，不需要连续。


■ 无需账号即可开始

不用注册，也不用登录。专注记录保存在你的设备上，我们不收集个人信息。为展示广告会使用广告标识符（Google Mobile Ads）。


■ RandomFocus Pro（可选）

一次性购买即可去除广告，自定义专注时长以及每个时长出现的概率，并把常用组合保存为预设。不是订阅。转盘、计时器、记录和 D-Day 目标都免费。


■ 支持四种语言

中文、英文、韩文和西班牙文。应用会自动跟随设备语言，也可以在设置中自行选择。


适合备考、作业和工作——凡是"开始最难"的事情。


隐私政策: https://docs.google.com/document/d/e/2PACX-1vShowtzVPBEdPtpYgWt0oFfhj0yz2BTL6Nb0n3NHavgb0giAcQA2TbT4nnL3mEk1ayjrLqHxf1egHqh/pub
支持邮箱: jacobooh7307@gmail.com
```

## 新功能 — 限 500 字符

```
• 新增韩文支持。应用会跟随设备语言，也可在设置中自行选择。
• 新增 D-Day 目标，倒数距离重要日期还有多少天。
```

---

# 적용 체크리스트

- [ ] ko-KR 자세한 설명 — **기존 내용을 전부 지우고** 위 블록만 붙여넣기
      (현재 한국어 + 스페인어가 섞여 있다)
- [ ] ko-KR 앱 이름 — `RandomFocus` → `RandomFocus - 공부 집중 타이머`
- [ ] ko-KR 간단한 설명 교체
- [ ] ko-KR 새로운 기능 — 현재 영어로 노출 중, 위 한국어로 교체
- [ ] en-US 3개 필드 교체
- [ ] es-419 3개 필드 교체
- [ ] zh-CN 로케일 **신규 추가** (앱은 지원하지만 등록정보가 없음)
- [ ] 각 로케일 저장 후 스토어 페이지에서 다른 언어 혼입 여부 확인
- [ ] 스크린샷은 이번에 건드리지 않는다 — 문안 변경 효과를 분리해 측정한다
