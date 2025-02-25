[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=17845113&assignment_repo_type=AssignmentRepo)
# Entrega 1 del proyecto WP01
# Informe Inicial: Proyecto "Snake"
## Integrantes
**Deyvid Santafe Quicazaque**
**Alejandro Zapata**
**Juan Rojas**
## 1. Introducción
El proyecto "Snake Game" en FPGA tiene como objetivo principal diseñar e implementar una versión interactiva del clásico juego de la serpiente, incorporando un nivel de innovación mediante el uso de sensores, para el control de la serpiente. Este enfoque no solo busca mejorar la experiencia de juego, haciéndola más inmersiva y desafiante, sino también ofrecer un reto técnico que permita aplicar los conceptos fundamentales de Electrónica Digital aprendidos durante el curso.

El proyecto servirá como un ejercicio integrador de los conocimientos adquiridos, abarcando temas como la lógica combinacional y secuencial, las máquinas de estado algorítmico (ASM), el diseño de datapaths y unidades de control, y la implementación en HDL.

## 2. Especificación del Sistema
### Componentes Principales
1. **FPGA**: Plataforma central del proyecto, encargada de la implementación lógica del juego.
2. **Sensores**: Sensor que medirá la inclinación para determinar la dirección de movimiento de la serpiente.
3. **Pantalla VGA**: Dispositivo de salida para mostrar el tablero y el estado del juego.
5. **Módulo de Generación de Gráficos**: Encargado de la visualización de los elementos del juego en la pantalla VGA.
6. **Módulo de Interfaz del Acelerómetro**: Convertirá las señales analógicas o digitales del sensor en datos que puedan ser interpretados por la FPGA.

### Descripción Funcional
- **Entrada**: Señales del acelerómetro que definen la dirección de movimiento.
- **Proceso**:
  - La FPGA analiza las entradas del acelerómetro para determinar las instrucciones de control.
  - El sistema actualiza el estado del juego mediante una FSM que gestiona el movimiento de la serpiente, la detección de colisiones y la generación de comida.
- **Salida**: Gráficos del juego renderizados en la pantalla VGA.

### Diagrama de Caja Negra
![image](https://github.com/user-attachments/assets/1d9a46f2-b2a8-41c9-b0f3-2c2223a98dd4)

## 3. Arquitectura del Sistema
### Definición de Periféricos y Módulos
1. **Sensores**:
   - **Función**: Detectar cambios en la inclinación para controlar la dirección de la serpiente.
   - **Conexión**: A través de un módulo de interfaz (I2C o SPI, dependiendo del sensor seleccionado) conectado a la FPGA.
2. **Generador de Gráficos**:
   - **Función**: Dibujar la serpiente, la comida y el tablero en la pantalla VGA.
   - **Conexión**: Recibe instrucciones de la FSM y envía señales a la pantalla.

3. **Pantalla VGA**:
   - **Función**: Mostrar el estado del juego.
   - **Conexión**: Directamente al módulo de generación de gráficos.

### Plan Inicial de Arquitectura
El sistema se dividirá en módulos funcionales que interactúan entre sí mediante buses de datos y señales de control. Se priorizará la simulación de cada componente antes de su integración.

## 4. Innovación
La elección de un sensor como dispositivo de entrada representa una mejora significativa respecto al control tradicional con joysticks o teclas. Este sensor aumenta la interactividad del juego, desafiando al jugador a controlar la serpiente mediante movimientos físicos. Desde el punto de vista técnico, implica el diseño de un sistema de lectura y procesamiento de datos del sensor, así como la implementación de algoritmos que traduzcan estas señales en comandos precisos para la FSM del juego.

## 5. Plan Inicial de Implementación
1. **Etapa 1: Diseño y Simulación**
   - Diseñar y simular la FSM del juego.
   - Implementar un módulo básico de generación de gráficos en VGA.
2. **Etapa 2: Interfaz del Acelerómetro**
   - Diseñar el módulo de lectura del acelerómetro.
   - Simular y verificar la recepción de datos.
3. **Etapa 3: Integración y Pruebas**
   - Integrar la FSM, la generación de gráficos y la entrada del acelerómetro.
   - Realizar pruebas en hardware.

## 6. Documentación Git
Se creará un repositorio en Git que incluirá:
- Diseños iniciales y diagramas.
- Código fuente en HDL (Verilog o VHDL).
- Simulaciones y resultados.
- Documentación clara de cada módulo.
