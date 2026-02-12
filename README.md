# ios-precision-calc

![Swift](https://img.shields.io/badge/Swift-F05138?style=flat&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-0071E3?style=flat&logo=swift&logoColor=white)
![SceneKit](https://img.shields.io/badge/SceneKit-333333?style=flat&logo=apple&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-16%2B-000000?style=flat&logo=apple&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=flat)

Dual-mode iOS calculator combining standard arithmetic with arbitrary-precision numbers and an interactive geometry calculator featuring SceneKit 3D visualization. Switch between precise everyday calculations and exploring 2D/3D shapes — all in one app.

## Features

### Standard Calculator
- **Arbitrary Precision Arithmetic** — custom `BigNumber` class supporting infinite-digit calculations with no overflow
- **Core Operations** — addition, subtraction, multiplication, division with full decimal support
- **Animated Gradient Backgrounds** — smooth, visually appealing animated gradients

### Geometry Calculator

#### 2D Shapes (9)
Circle, Rectangle, Triangle, Square, Hexagon, Ellipse, Parallelogram, Trapezoid, Rhombus

#### 3D Shapes (8)
Sphere, Cube, Rectangular Prism, Cylinder, Cone, Pyramid, Torus

- **SceneKit 3D Rendering** — interactive 3D previews of every solid shape with rotation and zoom
- **Area & Volume** — automatic computation of area (2D) and surface area / volume (3D)

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift |
| UI Framework | SwiftUI |
| 3D Rendering | SceneKit |
| Arithmetic | Custom BigNumber implementation |
| Animations | SwiftUI gradient animations |

## Getting Started

### Requirements

- Xcode 15.0 or later
- iOS 16.0+ deployment target
- macOS Ventura or later (for building)

### Installation

```bash
git clone https://github.com/selter2001/ios-precision-calc.git
cd ios-precision-calc
open ios-kalkulator.xcodeproj
```

Select your target device or simulator and press **Cmd + R** to build and run.

## Architecture

The project is organized around SwiftUI views with a dedicated `BigNumber` type handling all arithmetic:

```
├── App
│   └── ios-kalkulator/
├── Views
│   ├── ContentView.swift
│   ├── StandardCalculatorView.swift
│   └── GeometryCalculatorView.swift
├── Models
│   ├── CalculatorEngine.swift
│   └── GeometryModels.swift
└── SceneKit
    └── (3D shape scene builders)
```

- **CalculatorEngine / BigNumber** — custom arbitrary-precision number class supporting addition, subtraction, multiplication, and division without native type limitations
- **GeometryModels** — data definitions for all 2D and 3D shapes with formula computations
- **GeometryCalculatorView** — unified view with input forms, results, and SceneKit 3D previews for each shape
- **StandardCalculatorView** — full-featured calculator interface with BigNumber-backed operations

## Author

**Wojciech Olszak** — [@selter2001](https://github.com/selter2001)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

# ios-precision-calc

Dwutrybowy kalkulator na iOS łączący standardową arytmetykę z liczbami o dowolnej precyzji oraz interaktywny kalkulator geometryczny z wizualizacją 3D w SceneKit. Przełączaj się między precyzyjnymi codziennymi obliczeniami a eksploracją kształtów 2D/3D — wszystko w jednej aplikacji.

## Funkcje

### Kalkulator standardowy
- **Arytmetyka dowolnej precyzji** — własna klasa `BigNumber` obsługująca obliczenia na nieskończonej liczbie cyfr bez przepełnienia
- **Podstawowe operacje** — dodawanie, odejmowanie, mnożenie, dzielenie z pełną obsługą liczb dziesiętnych
- **Animowane tła gradientowe** — płynne, estetyczne animowane gradienty

### Kalkulator geometryczny

#### Kształty 2D (9)
Koło, Prostokąt, Trójkąt, Kwadrat, Sześciokąt, Elipsa, Równoległobok, Trapez, Romb

#### Kształty 3D (8)
Sfera, Sześcian, Prostopadłościan, Walec, Stożek, Ostrosłup, Torus

- **Rendering 3D w SceneKit** — interaktywne podglądy 3D każdej bryły z obrotem i zoomem
- **Pole i objętość** — automatyczne obliczanie pola (2D) oraz pola powierzchni / objętości (3D)

## Stos technologiczny

| Warstwa | Technologia |
|---|---|
| Język | Swift |
| Framework UI | SwiftUI |
| Rendering 3D | SceneKit |
| Arytmetyka | Własna implementacja BigNumber |
| Animacje | Animacje gradientów SwiftUI |

## Jak zacząć

### Wymagania

- Xcode 15.0 lub nowszy
- Target wdrożeniowy iOS 16.0+
- macOS Ventura lub nowszy (do kompilacji)

### Instalacja

```bash
git clone https://github.com/selter2001/ios-precision-calc.git
cd ios-precision-calc
open ios-kalkulator.xcodeproj
```

Wybierz urządzenie docelowe lub symulator i naciśnij **Cmd + R**, aby zbudować i uruchomić projekt.

## Architektura

Projekt jest zorganizowany wokół widoków SwiftUI z dedykowanym typem `BigNumber` obsługującym całą arytmetykę:

```
├── App
│   └── ios-kalkulator/
├── Views
│   ├── ContentView.swift
│   ├── StandardCalculatorView.swift
│   └── GeometryCalculatorView.swift
├── Models
│   ├── CalculatorEngine.swift
│   └── GeometryModels.swift
└── SceneKit
    └── (buildery scen kształtów 3D)
```

- **CalculatorEngine / BigNumber** — własna klasa liczbowa o dowolnej precyzji, obsługująca dodawanie, odejmowanie, mnożenie i dzielenie bez ograniczeń typów natywnych
- **GeometryModels** — definicje danych dla wszystkich kształtów 2D i 3D z obliczeniami wzorów
- **GeometryCalculatorView** — zunifikowany widok z formularzami, wynikami i podglądami 3D SceneKit dla każdego kształtu
- **StandardCalculatorView** — pełnofunkcyjny interfejs kalkulatora oparty na operacjach BigNumber

## Autor

**Wojciech Olszak** — [@selter2001](https://github.com/selter2001)

## Licencja

Projekt jest objęty licencją MIT. Szczegóły w pliku [LICENSE](LICENSE).
