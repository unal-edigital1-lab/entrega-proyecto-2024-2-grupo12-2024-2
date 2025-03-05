module snake_game (
    // Puertos de entrada/salida
    input wire clk50,
    input wire echo1,
    input wire echo2,
    output reg trig1,
    output reg trig2,
    output reg hsync,
    output reg vsync,
    output reg [2:0] rgb,
    output reg [3:0] leds
);

    //////////////////////////////////////////////////
    // 1. PARÁMETROS DEL SISTEMA
    //////////////////////////////////////////////////
    // Configuración ultrasónica
    parameter CLK_FREQ = 50_000_000;
    parameter US_DIV = 50;
    parameter TRIG_DURATION = 10;
    parameter THRESHOLD1 = 1160;  // 20cm (1160µs)
    parameter THRESHOLD2 = 2320;  // 40cm (2320µs)
    
    // Configuración del juego
    parameter SPEED_DIVIDER = 6_250_000;  // 0.5Hz
    parameter H_VISIBLE_AREA = 640;
    parameter V_VISIBLE_AREA = 480;
    parameter GRID_SIZE = 10;
    parameter MAX_LENGTH = 32;
    parameter BORDER_WIDTH = 1;  // Ancho del borde en celdas

    //////////////////////////////////////////////////
    // 2. REGISTROS Y CABLES
    //////////////////////////////////////////////////
    // Relojes
    reg clk25 = 0;
    reg [24:0] speed_counter = 0;
    wire slow_clk;
    
    // Sensores ultrasónicos
    reg [15:0] us_counter1, us_counter2;
    reg [24:0] main_counter1, main_counter2;
    reg [1:0] state1, state2;
    reg echo1_sync1, echo1_sync2;
    reg echo2_sync1, echo2_sync2;
    
    // Lógica del juego
    reg [9:0] h_count = 0, v_count = 0;
    reg [6:0] snake_x [0:MAX_LENGTH-1];
    reg [6:0] snake_y [0:MAX_LENGTH-1];
    reg [4:0] snake_length;
    reg [6:0] food_x, food_y;
    reg [1:0] direction;
    reg reset = 0;
    
    // Estados
    localparam [1:0]
        IDLE      = 2'b00,
        TRIG      = 2'b01,
        WAIT_ECHO = 2'b10,
        MEASURE   = 2'b11;

    integer i, j;

    //////////////////////////////////////////////////
    // 3. GENERACIÓN DE RELOJES
    //////////////////////////////////////////////////
    always @(posedge clk50) begin
        clk25 <= ~clk25;  // 25MHz
        
        if (speed_counter == SPEED_DIVIDER) speed_counter <= 0;
        else speed_counter <= speed_counter + 1;
    end
    assign slow_clk = (speed_counter == SPEED_DIVIDER);

    //////////////////////////////////////////////////
    // 4. LÓGICA ULTRASÓNICA (SENSORES)
    //////////////////////////////////////////////////
    always @(posedge clk50) begin
        echo1_sync1 <= echo1; echo1_sync2 <= echo1_sync1;
        echo2_sync1 <= echo2; echo2_sync2 <= echo2_sync1;
    end

    // Sensor 1 (Vertical: Arriba/Abajo)
    always @(posedge clk50) begin
        case(state1)
            IDLE: begin
                trig1 <= 0;
                if(main_counter1 == CLK_FREQ/16) begin
                    state1 <= TRIG;
                    main_counter1 <= 0;
                end
                else main_counter1 <= main_counter1 + 1;
            end
            
            TRIG: begin
                trig1 <= 1;
                if(us_counter1 == (TRIG_DURATION * US_DIV) - 1) begin
                    trig1 <= 0;
                    state1 <= WAIT_ECHO;
                    us_counter1 <= 0;
                end
                else us_counter1 <= us_counter1 + 1;
            end
            
            WAIT_ECHO: begin
                if(echo1_sync2) begin
                    state1 <= MEASURE;
                    main_counter1 <= 0;
                end
                else if(main_counter1 > CLK_FREQ/2) state1 <= IDLE;
                else main_counter1 <= main_counter1 + 1;
            end
            
            MEASURE: begin
                if(!echo1_sync2) begin
                    state1 <= IDLE;
                    leds[1:0] <= (main_counter1 < THRESHOLD1) ? 2'b01 :
                                (main_counter1 < THRESHOLD2) ? 2'b10 : 2'b00;
                end
                else if(us_counter1 == US_DIV - 1) begin
                    main_counter1 <= main_counter1 + 1;
                    us_counter1 <= 0;
                end
                else us_counter1 <= us_counter1 + 1;
            end
        endcase
    end

    // Sensor 2 (Horizontal: Izquierda/Derecha)
    always @(posedge clk50) begin
        case(state2)
            IDLE: begin
                trig2 <= 0;
                if(main_counter2 == CLK_FREQ/16) begin
                    state2 <= TRIG;
                    main_counter2 <= 0;
                end
                else main_counter2 <= main_counter2 + 1;
            end
            
            TRIG: begin
                trig2 <= 1;
                if(us_counter2 == (TRIG_DURATION * US_DIV) - 1) begin
                    trig2 <= 0;
                    state2 <= WAIT_ECHO;
                    us_counter2 <= 0;
                end
                else us_counter2 <= us_counter2 + 1;
            end
            
            WAIT_ECHO: begin
                if(echo2_sync2) begin
                    state2 <= MEASURE;
                    main_counter2 <= 0;
                end
                else if(main_counter2 > CLK_FREQ/2) state2 <= IDLE;
                else main_counter2 <= main_counter2 + 1;
            end
            
            MEASURE: begin
                if(!echo2_sync2) begin
                    state2 <= IDLE;
                    leds[3:2] <= (main_counter2 < THRESHOLD1) ? 2'b01 :
                                 (main_counter2 < THRESHOLD2) ? 2'b10 : 2'b00;
                end
                else if(us_counter2 == US_DIV - 1) begin
                    main_counter2 <= main_counter2 + 1;
                    us_counter2 <= 0;
                end
                else us_counter2 <= us_counter2 + 1;
            end
        endcase
    end

    //////////////////////////////////////////////////
    // 5. LÓGICA PRINCIPAL DEL JUEGO (CORREGIDA)
    //////////////////////////////////////////////////
    // Inicialización y movimiento unificados
    always @(posedge clk25) begin
        if (reset) begin
            // Reiniciar el juego
            for (i = 0; i < MAX_LENGTH; i = i + 1) begin
                snake_x[i] <= 32;  // Posición inicial X
                snake_y[i] <= 24;  // Posición inicial Y
            end
            snake_length <= 1;     // Longitud inicial
            food_x <= 10;          // Comida inicial X
            food_y <= 15;          // Comida inicial Y
            direction <= 2'b00;    // Dirección inicial
        end
        else if (slow_clk) begin
            // Control direccional
            casex({leds[1:0], leds[3:2]})
                4'b01??: direction <= 2'b10;  // Arriba
                4'b10??: direction <= 2'b11;  // Abajo
                4'b??01: direction <= 2'b00;  // Derecha
                4'b??10: direction <= 2'b01;  // Izquierda
            endcase

            // Actualizar cuerpo
            for (i = MAX_LENGTH-1; i > 0; i = i - 1) begin
                snake_x[i] <= snake_x[i-1];
                snake_y[i] <= snake_y[i-1];
            end

            // Mover cabeza
            case (direction)
                2'b00: snake_x[0] <= (snake_x[0] + 1) % 64;  // Derecha
                2'b01: snake_x[0] <= (snake_x[0] - 1 + 64) % 64;  // Izquierda
                2'b10: snake_y[0] <= (snake_y[0] - 1 + 48) % 48;  // Arriba
                2'b11: snake_y[0] <= (snake_y[0] + 1) % 48;  // Abajo
            endcase

            // Comer comida
            if (snake_x[0] == food_x && snake_y[0] == food_y) begin
                food_x <= (food_x + 17) % 64;
                food_y <= (food_y + 23) % 48;
                if (snake_length < MAX_LENGTH) snake_length <= snake_length + 1;
            end
        end
    end

    // Detección de colisión con bordes
    wire border_collision = (snake_x[0] < BORDER_WIDTH) || 
                          (snake_x[0] >= 64 - BORDER_WIDTH) ||
                          (snake_y[0] < BORDER_WIDTH) || 
                          (snake_y[0] >= 48 - BORDER_WIDTH);

    // Control de reset
    always @(posedge clk25) begin
        if (slow_clk && border_collision) reset <= 1;
        else reset <= 0;
    end

    //////////////////////////////////////////////////
    // 6. GENERACIÓN DE VGA CON BORDES
    //////////////////////////////////////////////////
    always @(posedge clk25) begin
        if (h_count < H_VISIBLE_AREA && v_count < V_VISIBLE_AREA) begin
            // Dibujar bordes blancos (10px de ancho)
            if ((h_count < GRID_SIZE*BORDER_WIDTH) || 
               (h_count >= H_VISIBLE_AREA - GRID_SIZE*BORDER_WIDTH) ||
               (v_count < GRID_SIZE*BORDER_WIDTH) || 
               (v_count >= V_VISIBLE_AREA - GRID_SIZE*BORDER_WIDTH)) 
            begin
                rgb <= 3'b111;  // Blanco
            end
            else begin
                // Fondo negro
                rgb <= 3'b000;
                
                // Dibujar serpiente
                for (j = 0; j < MAX_LENGTH; j = j + 1) begin
                    if (j < snake_length && 
                       (h_count/GRID_SIZE == snake_x[j]) && 
                       (v_count/GRID_SIZE == snake_y[j])) 
                    begin
                        rgb <= 3'b010;  // Verde
                    end
                end
                
                // Dibujar comida
                if ((h_count/GRID_SIZE == food_x) && 
                   (v_count/GRID_SIZE == food_y)) 
                begin
                    rgb <= 3'b100;  // Rojo
                end
            end
        end 
        else begin
            rgb <= 3'b000;  // Zona no visible
        end

        // Contadores VGA
        if (h_count < 799) h_count <= h_count + 1;
        else begin
            h_count <= 0;
            v_count <= (v_count < 524) ? v_count + 1 : 0;
        end

        // Sincronización
        hsync <= (h_count >= 656 && h_count < 752);
        vsync <= (v_count >= 490 && v_count < 492);
    end

endmodule