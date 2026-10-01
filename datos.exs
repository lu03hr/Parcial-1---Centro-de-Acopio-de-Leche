# Integrantes: Luisa Hernández, Isabella Hincapié, Camila González
# Datos de prueba: 10 productores, 4 tanques, 84 entregas válidas y 12 inválidas

defmodule Datos do
  def productores do
    [
      %{codigo: "P01", nombre: "Luisa Hernández", transporte: true},
      %{codigo: "P02", nombre: "Isabella Hincapié", transporte: false},
      %{codigo: "P03", nombre: "Camila González", transporte: true},
      %{codigo: "P04", nombre: "Sandro Rendón", transporte: true},
      %{codigo: "P05", nombre: "Danna Vélez", transporte: true},
      %{codigo: "P06", nombre: "Maryory Restrepo", transporte: false},
      %{codigo: "P07", nombre: "Santiago Rosas", transporte: false},
      %{codigo: "P08", nombre: "María Durán", transporte: true},
      %{codigo: "P09", nombre: "Rony López", transporte: true},
      %{codigo: "P10", nombre: "Omar Cortés", transporte: false}
    ]
  end

  def tanques do
    [
      %{id: "T1", nombre: "Tanque Norte", capacidad: 5000},
      %{id: "T2", nombre: "Tanque Central", capacidad: 4000},
      %{id: "T3", nombre: "Tanque Sur", capacidad: 3000},
      %{id: "T4", nombre: "Tanque Oeste", capacidad: 5100}
    ]
  end

  def entregas do
    [
        # Entregas dia 1
      %{productor: "P01", tanque: "T1", dia: 1, litros: 240, grasa: 3.8},
      %{productor: "P01", tanque: "T2", dia: 1, litros: 230, grasa: 2.9},
      %{productor: "P02", tanque: "T4", dia: 1, litros: 160, grasa: 2.2},
      %{productor: "P02", tanque: "T3", dia: 1, litros: 133, grasa: 4.3},
      %{productor: "P03", tanque: "T1", dia: 1, litros: 139, grasa: 2.7},
      %{productor: "P04", tanque: "T4", dia: 1, litros: 140, grasa: 3.7},
      %{productor: "P04", tanque: "T4", dia: 1, litros: 50, grasa: 3.0},
      %{productor: "P04", tanque: "T1", dia: 1, litros: 235, grasa: 3.4},
      %{productor: "P04", tanque: "T1", dia: 1, litros: 207, grasa: 4.0},
      %{productor: "P05", tanque: "T1", dia: 1, litros: 205, grasa: 2.8},
      %{productor: "P05", tanque: "T2", dia: 1, litros: 96.5, grasa: 3.2},
      %{productor: "P06", tanque: "T3", dia: 1, litros: 140, grasa: 2.3},
      %{productor: "P09", tanque: "T3", dia: 1, litros: 185.5, grasa: 3.5},
      %{productor: "P09", tanque: "T1", dia: 1, litros: 160, grasa: 3.4},
      %{productor: "P09", tanque: "T1", dia: 1, litros: 41.5, grasa: 3.3},
      # Entregas dia 2
      %{productor: "P01", tanque: "T4", dia: 2, litros: 60, grasa: 3.6},
      %{productor: "P02", tanque: "T3", dia: 2, litros: 250, grasa: 8.3},
      %{productor: "P02", tanque: "T2", dia: 2, litros: 135, grasa: 2.9},
      %{productor: "P02", tanque: "T1", dia: 2, litros: 75, grasa: 2.5},
      %{productor: "P02", tanque: "T2", dia: 2, litros: 97, grasa: 3.6},
      %{productor: "P02", tanque: "T1", dia: 2, litros: 71, grasa: 2.8},
      %{productor: "P04", tanque: "T1", dia: 2, litros: 150, grasa: 3.5},
      %{productor: "P05", tanque: "T2", dia: 2, litros: 200, grasa: 2.3},
      %{productor: "P06", tanque: "T3", dia: 2, litros: 130, grasa: 2.7},
      %{productor: "P06", tanque: "T3", dia: 2, litros: 130, grasa: 3.4},
      %{productor: "P06", tanque: "T3", dia: 2, litros: 179, grasa: 2.6},
      %{productor: "P07", tanque: "T3", dia: 2, litros: 50, grasa: 4.8},
      %{productor: "P08", tanque: "T4", dia: 2, litros: 168, grasa: 4.3},
      %{productor: "P09", tanque: "T4", dia: 2, litros: 170, grasa: 3.6},
      %{productor: "P09", tanque: "T4", dia: 2, litros: 145, grasa: 3.6},
      # Entregas dia 3
      %{productor: "P01", tanque: "T3", dia: 3, litros: 180, grasa: 3.6},
      %{productor: "P01", tanque: "T4", dia: 3, litros: 125, grasa: 2.3},
      %{productor: "P01", tanque: "T3", dia: 3, litros: 60, grasa: 2.6},
      %{productor: "P02", tanque: "T2", dia: 3, litros: 98.5, grasa: 3.6},
      %{productor: "P03", tanque: "T4", dia: 3, litros: 100, grasa: 3.7},
      %{productor: "P03", tanque: "T1", dia: 3, litros: 69, grasa: 3.7},
      %{productor: "P04", tanque: "T4", dia: 3, litros: 54, grasa: 4.2},
      %{productor: "P05", tanque: "T2", dia: 3, litros: 400, grasa: 8.3},
      %{productor: "P05", tanque: "T1", dia: 3, litros: 44.5, grasa: 4.4},
      %{productor: "P06", tanque: "T4", dia: 3, litros: 49.5, grasa: 3.5},
      %{productor: "P06", tanque: "T1", dia: 3, litros: 85, grasa: 3.7},
      %{productor: "P07", tanque: "T1", dia: 3, litros: 600, grasa: 2.6},
      # Entregas dia 4
      %{productor: "P01", tanque: "T2", dia: 4, litros: 50, grasa: 3.7},
      %{productor: "P01", tanque: "T1", dia: 4, litros: 195, grasa: 2.4},
      %{productor: "P01", tanque: "T1", dia: 4, litros: 65, grasa: 4.0},
      %{productor: "P02", tanque: "T4", dia: 4, litros: 94.5, grasa: 2.8},
      %{productor: "P02", tanque: "T1", dia: 4, litros: 185, grasa: 2.6},
      %{productor: "P02", tanque: "T1", dia: 4, litros: 51, grasa: 3.6},
      %{productor: "P03", tanque: "T2", dia: 4, litros: 102, grasa: 2.5},
      %{productor: "P04", tanque: "T3", dia: 4, litros: 170, grasa: 3.0},
      %{productor: "P04", tanque: "T3", dia: 4, litros: 65, grasa: 4.3},
      %{productor: "P04", tanque: "T2", dia: 4, litros: 88.5, grasa: 3.7},
      %{productor: "P05", tanque: "T1", dia: 4, litros: 165, grasa: 3.8},
      %{productor: "P05", tanque: "T3", dia: 4, litros: 94, grasa: 2.7},
      %{productor: "P06", tanque: "T4", dia: 4, litros: 460, grasa: 9.1},
      %{productor: "P08", tanque: "T3", dia: 4, litros: 460, grasa: 3.3},
      %{productor: "P09", tanque: "T4", dia: 4, litros: 110, grasa: 2.4},
      # Entregas dia 5
      %{productor: "P01", tanque: "T4", dia: 5, litros: 210, grasa: 3.3},
      %{productor: "P01", tanque: "T1", dia: 5, litros: 60, grasa: 3.7},
      %{productor: "P01", tanque: "T4", dia: 5, litros: 46.5, grasa: 3.5},
      %{productor: "P02", tanque: "T2", dia: 5, litros: 75, grasa: 2.3},
      %{productor: "P03", tanque: "T1", dia: 5, litros: 58.5, grasa: 3.9},
      %{productor: "P06", tanque: "T1", dia: 5, litros: 230, grasa: 2.6},
      %{productor: "P06", tanque: "T1", dia: 5, litros: 67, grasa: 2.7},
      %{productor: "P06", tanque: "T2", dia: 5, litros: 138.5, grasa: 2.9},
      %{productor: "P07", tanque: "T2", dia: 5, litros: 420, grasa: 2.7},
      %{productor: "P09", tanque: "T2", dia: 5, litros: 115, grasa: 3.7},
      %{productor: "P09", tanque: "T4", dia: 5, litros: 70, grasa: 2.7},
      %{productor: "P09", tanque: "T2", dia: 5, litros: 124, grasa: 3.7},
      # Entregas dia 6
      %{productor: "P02", tanque: "T1", dia: 6, litros: 165, grasa: 4.1},
      %{productor: "P02", tanque: "T4", dia: 6, litros: 136, grasa: 2.3},
      %{productor: "P03", tanque: "T3", dia: 6, litros: 230, grasa: 2.5},
      %{productor: "P03", tanque: "T3", dia: 6, litros: 211.5, grasa: 3.3},
      %{productor: "P03", tanque: "T3", dia: 6, litros: 70, grasa: 4.0},
      %{productor: "P04", tanque: "T2", dia: 6, litros: 230, grasa: 1.5},
      %{productor: "P05", tanque: "T1", dia: 6, litros: 300, grasa: 3.1},
      %{productor: "P05", tanque: "T4", dia: 6, litros: 260.5, grasa: 3.6},
      %{productor: "P05", tanque: "T4", dia: 6, litros: 144, grasa: 4.3},
      %{productor: "P05", tanque: "T1", dia: 6, litros: 40, grasa: 3.0},
      %{productor: "P06", tanque: "T2", dia: 6, litros: 45, grasa: 4.4},
      %{productor: "P06", tanque: "T2", dia: 6, litros: 53.5, grasa: 2.6},
      %{productor: "P08", tanque: "T2", dia: 6, litros: 140, grasa: 2.3},
      %{productor: "P08", tanque: "T4", dia: 6, litros: 228.5, grasa: 3.2},
      %{productor: "P09", tanque: "T4", dia: 6, litros: 217.5, grasa: 3.9},

      #  Entregas con errores y su motivo de rechazo
      # productor_desconocido
      %{productor: "P99", tanque: "T1", dia: 2, litros: 200, grasa: 3.5},
      # productor_desconocido (código en minúscula)
      %{productor: "p03", tanque: "T2", dia: 3, litros: 150, grasa: 3.2},
      # tanque_desconocido
      %{productor: "P03", tanque: "T9", dia: 1, litros: 180, grasa: 3.4},
      # tanque_desconocido
      %{productor: "P06", tanque: "T5", dia: 4, litros: 210, grasa: 3.3},
      # dia_invalido (día 7)
      %{productor: "P08", tanque: "T1", dia: 7, litros: 210, grasa: 3.3},
      # dia_invalido (día 0)
      %{productor: "P10", tanque: "T2", dia: 0, litros: 190, grasa: 3.6},
      # dia_invalido (el día es texto)
      %{productor: "P09", tanque: "T3", dia: "3", litros: 150, grasa: 3.0},
      # litros_fuera_de_rango (más de 800)
      %{productor: "P10", tanque: "T1", dia: 3, litros: 950, grasa: 3.5},
      # litros_fuera_de_rango (cero litros)
      %{productor: "P05", tanque: "T4", dia: 5, litros: 0, grasa: 3.2},
      # porcentaje_invalido (más de 15)
      %{productor: "P06", tanque: "T3", dia: 1, litros: 200, grasa: 16.2},
      # porcentaje_invalido (negativo)
      %{productor: "P02", tanque: "T1", dia: 4, litros: 180, grasa: -1.0},
      # tiene varios errores: solo se reporta productor_desconocido, que es el primero que se encuentra :)
      %{productor: "P99", tanque: "T9", dia: 9, litros: 900, grasa: 20}
    ]
  end

  # Litros por día del centro de acopio vecino
  def centro_vecino do
    %{1 => 1850.5, 2 => 2100, 3 => 1640, 5 => 2350, 7 => 800}
  end
end
