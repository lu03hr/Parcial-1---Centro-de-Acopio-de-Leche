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
 %{codigo: "P09", nombre: "Rony López ", transporte: true},
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
 %{productor: "P01", tanque: "T1", dia: 1, litros: 240, grasa: 3.8},
 %{productor: "P01", tanque: "T2", dia: 1, litros: 230, grasa: 2.9},
 %{productor: "P02", tanque: "T3", dia: 2, litros: 250, grasa: 8.3},
 %{productor: "P05", tanque: "T2", dia: 3, litros: 400, grasa: 8.3},
 %{productor: "P06", tanque: "T4", dia: 4, litros: 460, grasa: 9.1},
 %{productor: "P06", tanque: "T1", dia: 5, litros: 230, grasa: 2.6},
 %{productor: "P04", tanque: "T2", dia: 6, litros: 230, grasa: 1.5},
 %{productor: "P03", tanque: "T3", dia: 6, litros: 230, grasa: 2.5}
 ]
    end
end
