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

---

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

## 6. Desarrollo Técnico y Descripción del Código
### Descripción Breve del Código Utilizado
El módulo principal, `snake_game`, se encarga de integrar todas las funcionalidades del juego. Entre sus bloques se incluyen:
- **Configuración y Parámetros:**  
  Define parámetros clave como la frecuencia de reloj, divisores de velocidad y umbrales para los sensores ultrasónicos.
- **Calibración de Sensores:**  
  Se implementan dos FSM (una para cada sensor) para generar el pulso de disparo y medir el tiempo de respuesta del HC-SR04. Aquí se sincroniza la señal de los sensores con el reloj de 50 MHz.  
  *Nota: El mayor reto fue precisamente calibrar estos sensores, ya que se deben sincronizar correctamente para obtener mediciones precisas y, a la vez, evitar interferencias en el sistema.*
- **Lógica del Juego y Movimiento de la Serpiente:**  
  Se utiliza una máquina de estados para gestionar el movimiento de la serpiente y actualizar su "cola" (arreglo de coordenadas). Se realiza una copia secuencial de las posiciones, lo que permite que la cola siga de manera coherente la cabeza del snake.  
  *Reto adicional:* Sincronizar la actualización de la "cola" con el reloj para que el movimiento sea fluido y sin desajustes.
- **Generación de la Señal VGA:**  
  Se dibujan la serpiente, la comida y los bordes del área de juego mediante la generación de señales sincronizadas (hsync, vsync) para una resolución de 640x480.
- **Detección de Colisiones y Reset:**  
  Se implementa lógica para detectar colisiones con bordes y con la misma serpiente, activando un reset del juego en caso de colisión.

### Comentarios del Código
Cada sección del código está comentada para explicar su funcionalidad. Por ejemplo, se describen los parámetros que controlan la velocidad y la calibración de los sensores, así como la forma en que se actualizan las posiciones de la serpiente en cada ciclo.

---

## 7. Simulaciones y Pruebas
### Resultados Clave
- **Validación mediante LEDs:**  
  - LEDs indican las direcciones detectadas por los sensores (vertical y horizontal).
- **Testbench y Simulaciones:**  
  Se han realizado simulaciones para verificar que:
  - La señal VGA se genera correctamente y sin parpadeos.
  - La lectura de los sensores se calibra adecuadamente.
  - El movimiento de la serpiente y la actualización de su cola ocurren de forma sincronizada.
  
| Parámetro               | Valor              |
|-------------------------|--------------------|
| Tiempo de respuesta     | <100 ms            |
| Velocidad del juego     | 4 fps              |
| Consumo de LUTs (FPGA)  | 45% aproximadamente|

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
- **Herramientas:**  
  Se utilizó GitHub para el control de versiones y WhatsApp para la coordinación.
- **Distribución de Tareas:**  
  | Integrante           | Responsabilidad                              |
  |----------------------|----------------------------------------------|
  | Deyvid Santafe       | Lógica del juego, calibración de sensores y VGA.|
  | Alejandro Zapata     | Interfaz de sensores, pruebas y simulaciones.|
  | Juan Rojas           | Documentación, testbenches y análisis de resultados.|

---

## 10. Documentación y Repositorio
### Estructura del Repositorio
```
/src
   └── snake_game.v        # Código HDL principal
   └── constraints.xdc     # Asignación de pines
/qpf
   └── vga.qpf            # Simulación Quartus
README.md                 # Este archivo
```
- **Estándares de Código:**  
  Se han utilizado nombres descriptivos y comentarios detallados en cada módulo para facilitar la comprensión y el mantenimiento.

---

## 11. Demostración y Resultados
### Funcionamiento:
  - Conectar sensores a pines GPIO trigger y echo
  - Programar FPGA y conectar pantalla VGA.
  - Jugar usando gestos de proximidad.
---


## 12. Limitaciones y Mejoras Futuras
### Limitaciones Actuales
- Resolución gráfica fija en 640x480.
- Detección de colisiones básica (sólo bordes y colisión consigo mismo).
### Propuestas de Mejora
- Incluir un menú interactivo y puntuación utilizando una pantalla OLED.
- Implementar un modo multijugador con controles adicionales.
- Mejorar la calibración de sensores para una mayor precisión en entornos ruidosos.
- Optimizar la lógica de actualización de la cola para evitar cualquier desajuste.
