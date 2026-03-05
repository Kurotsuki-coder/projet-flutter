# 🌦️ SenMeteo — L3GL ISI 2026

Application Flutter météo en temps réel avec cartes interactives, animations et mode sombre/clair.

---

## 👥 Membres du Groupe

| Nom                    | Rôle                                        |
|------------------------|---------------------------------------------|
| Magatte Gaye           | Expert Animations & Maps (Interactif)       |
| Banami Da Silva Mango  | Architecte Data & API (Back-end Mobile)     |
| Abdoul Wahab Talla     | Maître de l'UI & UX (Designer)              |

---

## ⚙️ Installation

### 1. Cloner le repo
```bash
git clone https://github.com/VOTRE_USERNAME/application_meteo.git
cd application_meteo
```

### 2. Clé API OpenWeatherMap
Ouvrir `lib/core/constants/app_constants.dart` et remplacer :
```dart
static const String apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
```
Obtenir une clé gratuite sur [openweathermap.org](https://openweathermap.org/api).

### 3. Installer les dépendances
```bash
flutter pub get
```

### 4. Générer le code Retrofit (si besoin)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Lancer
```bash
flutter run
```

---

## 🗺️ Cartes
Les cartes utilisent **OpenStreetMap via flutter_map** — aucune clé API Google Maps requise.

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/app_constants.dart   ← Clé API, villes, timeouts
│   ├── errors/
│   │   ├── failures.dart              ← Failures typées (Either)
│   │   └── exceptions.dart            ← Exceptions brutes
│   ├── network/
│   │   ├── dio_client.dart            ← Dio + intercepteurs
│   │   └── network_info.dart          ← Vérification connectivité
│   └── theme.dart                     ← Thèmes clair/sombre
├── data/
│   ├── models/weather_model.dart      ← POJO + fromJson
│   ├── services/weather_api_service   ← Retrofit @GET /weather
│   ├── repositories/                  ← Contrat + implémentation
│   └── providers/weather_providers    ← Riverpod DI
└── ui/
    ├── home_screen.dart
    └── screens/
        ├── animations/principal.dart  ← Splash animé
        ├── animations/transition.dart ← Transition avion
        ├── detail/city_detail_screen  ← Carte + météo live
        └── main/main_screen.dart      ← Jauge + liste villes
```

---

## ⏰ Deadline : 05 mars 2026 à 23h59m59s
