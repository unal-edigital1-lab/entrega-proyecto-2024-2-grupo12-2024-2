[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=17845113&assignment_repo_type=AssignmentRepo)
# Proyecto WP01: Snake Game en FPGA con Control por Gestos
## Integrantes
**Deyvid Santafe Quicazaque**  
**Alejandro Zapata**  
**Juan Rojas**

---

## Tabla de Contenidos
1. [Introducción](#1-introducción)  
2. [Especificación del Sistema](#2-especificación-del-sistema)  
3. [Arquitectura del Sistema](#3-arquitectura-del-sistema)  
4. [Innovación](#4-innovación)  
5. [Plan de Implementación](#5-plan-de-implementación)  
6. [Desarrollo Técnico](#6-desarrollo-técnico)  
7. [Simulaciones y Pruebas](#7-simulaciones-y-pruebas)  
8. [Prototipo Final](#8-prototipo-final)  
9. [Trabajo en Equipo](#9-trabajo-en-equipo)  
10. [Documentación y Repositorio](#10-documentación-y-repositorio)  
11. [Demostración y Resultados](#11-demostración-y-resultados)  
12. [Limitaciones y Mejoras Futuras](#12-limitaciones-y-mejoras-futuras)  

---

## 1. Introducción
Este proyecto implementa el clásico juego **Snake** en una FPGA, utilizando **sensores ultrasónicos HC-SR04** para controlar el movimiento mediante gestos de proximidad. El objetivo es integrar electrónica digital, diseño HDL y periféricos para crear un sistema interactivo innovador, cumpliendo con las tres etapas del proyecto: especificación, desarrollo y prototipo final.

---

## 2. Especificación del Sistema
### Componentes Principales
| Componente              | Detalles Técnicos                                                                 |
|-------------------------|-----------------------------------------------------------------------------------|
| **FPGA**                | Basys 3 Artix-7 (50 MHz), 4 pines PMOD para sensores, salida VGA integrada.       |
| **Sensores**            | HC-SR04 (ultrasónico), protocolo Trigger/Echo, rango 2-400 cm (umbral: 20-40 cm).|
| **Pantalla VGA**        | Resolución 640x480 @ 60 Hz, 8 colores básicos (RGB 3 bits).                       |
| **Lógica del Juego**    | Máquina de estados (FSM), detección de colisiones, generación aleatoria de comida.|

### Diagrama de Caja Negra
![image](https://github.com/user-attachments/assets/7649681d-f2c5-4b72-ae7c-f25aa0b167ab)
---

## 3. Arquitectura del Sistema
### Diagrama de Bloques
```plaintext
+----------------+     +---------------------+     +-----------------+
| Sensores        |     | FPGA (Nexys 4)      |     | Pantalla VGA    |
| HC-SR04 (x2)   |<--->| - Interfaz Sensores  |<--->| 640x480         |
| Trigger/Echo    |     | - Lógica del Snake   |     | RGB 3 bits      |
+-----------------+     | - Generador VGA      |     +-----------------+
                        | - FSM de Colisiones  |
                        +----------------------
```
Funcionalidad Clave
1. **Control por Gestos:**
  - Sensor 1 (Horizontal): Proximidad <20 cm → Derecha; >40 cm → Izquierda.
  - Sensor 2 (Vertical): Proximidad <20 cm → Arriba; >40 cm → Abajo.

2. Mecánicas del Juego:
  - Colisiones: Reinicio automático al tocar bordes o el propio cuerpo.
  - Crecimiento: La serpiente aumenta de longitud al "comer" comida generada aleatoriamente.



## 4. Innovación
- Interacción sin Contacto: Elimina la necesidad de botones físicos, usando gestos para un control más inmersivo.
- Optimización de HDL: Implementación en un solo módulo Verilog con:
  - Máquinas de estado para sensores.
  - Temporizadores de velocidad ajustables (SPEED_DIVIDER).

## 4. Innovación
- **Interacción sin Contacto**: Elimina la necesidad de botones físicos, usando gestos para un control más inmersivo.  
- **Optimización de HDL**: Implementación en un solo módulo Verilog con:  
  - Máquinas de estado para sensores.  
  - Temporizadores de velocidad ajustables (`SPEED_DIVIDER`).  
  - Generación de gráficos en tiempo real.  

---

## 5. Plan de Implementación
### Etapas del Proyecto
| Etapa  | Objetivo                          | Logros                                                                 |
|--------|-----------------------------------|------------------------------------------------------------------------|
| **1**  | Especificación Inicial            | Diagramas de bloques, plan de simulación, documentación Git inicial.  |
| **2**  | Desarrollo y Simulación           | Integración VGA, lógica básica del juego, pruebas con LEDs.           |
| **3**  | Prototipo Final                   | Control por sensores, detección de colisiones, unificación de módulos.|

---

## 6. Desarrollo Técnico
### Módulos Principales
1. **Lógica del Juego**:  
   - **Movimiento basado en dirección (`direction`)**:  
     - `2'b00`: Derecha.  
     - `2'b01`: Izquierda.  
     - `2'b10`: Arriba.  
     - `2'b11`: Abajo.  
   - **Reinicio automático al detectar colisión (`game_reset`)**:  
     - Colisión con bordes o con el propio cuerpo.  
     - Reinicio de posición y longitud de la serpiente.  

2. **Generador VGA**:  
   - **Sincronización horizontal/vertical (`hsync`, `vsync`)**:  
     - Control de refresco de pantalla a 60 Hz.  
   - **Renderizado de serpiente y comida en cuadrícula 64x48**:  
     - Cada celda de la cuadrícula representa 10x10 píxeles en VGA.  
     - La serpiente se dibuja como un conjunto de cuadrados verdes (`rgb = 3'b010`).  
     - La comida se dibuja como un cuadrado rojo (`rgb = 3'b100`).  

---

## 7. Simulaciones y Pruebas
### Resultados Clave
- **Validación con LEDs**:  
  - `leds[1:0]`: Indicadores de dirección vertical (01=Arriba, 10=Abajo).  
  - `leds[3:2]`: Indicadores de dirección horizontal.  
- **Métricas**:  
  | Parámetro               | Valor              |
  |-------------------------|--------------------|
  | Tiempo de respuesta     | <100 ms            |
  | Velocidad del juego     | 4 fps              |
  | Consumo de LUTs (FPGA) | 45%                |

---

## 8. Prototipo Final
### Características
- **Interfaz de Usuario**:  
  - Control intuitivo por gestos.  
  - Feedback visual mediante LEDs y VGA.  
- **Rendimiento**:  
  - Funcionamiento estable a 50 MHz.  
  - Baja latencia en la respuesta de sensores.  

---

## 9. Trabajo en Equipo
### Gestión del Proyecto
- **Herramientas**: GitHub para control de versiones, WhatsApp para comunicación.  
- **Distribución de Tareas**:  
  | Integrante           | Responsabilidad                              |
  |----------------------|---------------------------------------------|
  | Deyvid Santafe       | Lógica del juego y integración VGA.         |
  | Alejandro Zapata     | Interfaz de sensores y pruebas.             |
  | Juan Rojas           | Documentación y simulación.                 |

---
## 10. Documentación y Repositorio
### Estructura del Repositorio
├── src/
│ ├── snake_game_with_ultrasonic.v # Código principal
│ └── constraints.xdc # Asignación de pines
├── docs/
│ ├── diagramas/ # Diagramas de bloques
│ └── especificaciones.pdf # Documentación técnica
└── README.md # Este archivo

### Estándares de Código
- **Convenciones**: Nombres descriptivos (ej: `snake_x`, `food_y`).  
- **Comentarios**: Explicación de parámetros críticos:  
  ```verilog
  parameter SPEED_DIVIDER = 6_250_000;  // Controla velocidad (ajustable)
---
11. Demostración y Resultados
Funcionamiento:
  - Conectar sensores a pines GPIO trigger y echo
  - Programar FPGA y conectar pantalla VGA.
  - Jugar usando gestos de proximidad.
---
12. Limitaciones y Mejoras Futuras
Limitaciones Actuales
  - Resolución Gráfica: Fija en 640x480.
  - Detección de Colisiones: Básica (solo bordes).
Propuestas de Mejora
  - Menú Interactivo: Usar pantalla OLED para puntuación.
  - Modo Multijugador: Dos serpientes controladas por 4 sensores.
