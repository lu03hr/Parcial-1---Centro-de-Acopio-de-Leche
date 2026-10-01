defmodule Vista do

  @raya "============================================================"

  def imprimir_reportes(reportes) do
    imprimir_r1(reportes.r1)
    imprimir_r2(reportes.r2)
    imprimir_r3(reportes.r3)
    imprimir_r4(reportes.r4)
    imprimir_r5(reportes.r5)
    imprimir_r6(reportes.r6)
    imprimir_r7(reportes.r7)
    imprimir_r8(reportes.r8)
  end


  def imprimir_r1(r1) do
    r1
    |> generar_mensaje_r1()
    |> Util2.mostrar(:mensaje)
  end

  def imprimir_r2(r2) do
    r2
    |> generar_mensaje_r2()
    |> Util2.mostrar(:mensaje)
  end

  def imprimir_r3(r3) do
    r3
    |> generar_mensaje_r3()
    |> Util2.mostrar(:mensaje)
  end

  def imprimir_r4(r4) do
    r4
    |> generar_mensaje_r4()
    |> Util2.mostrar(:mensaje)
  end

  def imprimir_r5(r5) do
    r5
    |> generar_mensaje_r5()
    |> Util2.mostrar(:mensaje)
  end

  def imprimir_r6(r6) do
    r6
    |> generar_mensaje_r6()
    |> Util2.mostrar(:mensaje)
  end

  def imprimir_r7(r7) do
    r7
    |> generar_mensaje_r7()
    |> Util2.mostrar(:mensaje)
  end

  def imprimir_r8(r8) do
    r8
    |> generar_mensaje_r8()
    |> Util2.mostrar(:mensaje)
  end

  # -------------------------------------------------------------------
  # GENERAR R1. Entregas rechazadas

  defp generar_mensaje_r1(r1) do
    [
      generar_titulo("Reporte 1. Entregas rechazadas"),
      generar_lineas_de_rechazadas(r1.entregas_rechazadas),
      "\nRechazos por motivo:\n",
      Util2.convertir_coleccion_mensaje(r1.cantidad_por_motivo, fn {motivo, cantidad} -> "  #{motivo}: #{cantidad}\n" end)
    ]
  end

  defp generar_lineas_de_rechazadas([]), do: "  No hubo entregas rechazadas.\n"

  defp generar_lineas_de_rechazadas(entregas_rechazadas) do
    Util2.convertir_coleccion_mensaje(entregas_rechazadas, fn {entrega, motivo} -> "  #{inspect(entrega)}  ->  #{motivo}\n" end)
  end


  # -------------------------------------------------------------------
  # GENERAR R2. Ocupación de tanques

  defp generar_mensaje_r2(filas_de_tanques) do
    [
      generar_titulo("Reporte 2. Ocupación de tanques (de mayor a menor)"),
      "  Tanque\tLitros\tCapacidad\tOcupación\n",
      Util2.convertir_coleccion_mensaje(filas_de_tanques, fn tanque ->
        litros = formatear_decimales(tanque.litros_almacenados, 1)
        capacidad = formatear_decimales(tanque.capacidad, 0)
        ocupacion = formatear_decimales(tanque.porcentaje_ocupacion, 1)
        "  #{tanque.nombre}\t#{litros}\t#{capacidad}\t#{ocupacion} %\n"
      end)
    ]
  end

  # -------------------------------------------------------------------
  # GENERAR R3. Litros por día y meta diaria

  defp generar_mensaje_r3(r3) do
    meta = formatear_decimales(Parametros.meta_diaria(), 0)
    [
      generar_titulo("Reporte 3. Litros recibidos por día (meta: #{meta} litros)"),
      Util2.convertir_coleccion_mensaje(r3.detalle_por_dia, fn dia ->
        litros = formatear_decimales(dia.litros, 1)
        "  Día #{dia.dia}: #{litros} L - Meta alcanzada: #{generar_si_o_no(dia.alcanzo_meta)}\n"
      end),
      "\n  ¿Se cumplió la meta todos los días? #{generar_si_o_no(r3.cumplio_todos_los_dias)}\n",
      "  ¿Se cumplió la meta al menos un día? #{generar_si_o_no(r3.cumplio_al_menos_un_dia)}\n"
    ]
  end

  # -------------------------------------------------------------------
  # GENERAR R4. Liquidación de productores

  defp generar_mensaje_r4(liquidacion_ordenada) do
    productores_numerados = Enum.with_index(liquidacion_ordenada, 1)

    [
      generar_titulo("Reporte 4. Liquidación de productores (por neto, de mayor a menor)"),
      "  #\tProductor\tLitros\tEntregas\tBonif.\tTransp.\tNeto\n",
      Util2.convertir_coleccion_mensaje(productores_numerados, fn {productor, numero} ->
        litros = formatear_decimales(productor.litros, 1)
        entregas = formatear_pesos(productor.valor_entregas)
        bonificaciones = formatear_pesos(productor.bonificaciones)
        transporte = formatear_pesos(productor.transporte)
        neto = formatear_pesos(productor.neto)
        "  #{numero}\t#{productor.nombre}\t#{litros}\t#{entregas}\t#{bonificaciones}\t#{transporte}\t#{neto}\n"
      end)
    ]
  end


  # -------------------------------------------------------------------
  # GENERAR R5. Mayor entregador de cada día

  defp generar_mensaje_r5(r5) do
    [
      generar_titulo("Reporte 5. Productor con más litros cada día"),
      Util2.convertir_coleccion_mensaje(r5.detalle_por_dia, fn dia -> generar_linea_de_dia_r5(dia) end),
      generar_linea_de_primer_lugar_r5(r5.primer_lugar_en_mas_dias)
    ]
  end

  defp generar_linea_de_dia_r5(%{productores_lideres: [], dia: dia}) do
    "  Día #{dia}: sin entregas válidas\n"
  end

  defp generar_linea_de_dia_r5(dia) do
    nombres = generar_texto_de_productores(dia.productores_lideres)
    litros = formatear_decimales(dia.litros_del_lider, 1)
    "  Día #{dia.dia}: #{nombres} con #{litros} L\n"
  end

  defp generar_linea_de_primer_lugar_r5(%{productores: []}) do
    "\n  Nadie ocupó el primer lugar.\n"
  end

  defp generar_linea_de_primer_lugar_r5(primer_lugar) do
    nombres = generar_texto_de_productores(primer_lugar.productores)
    "\n  Primer lugar en más días (#{primer_lugar.dias_en_primer_lugar} días): #{nombres}\n"
  end

  defp generar_texto_de_productores(fichas) do
    fichas
    |> Enum.map(fn ficha -> "#{ficha.nombre} (#{ficha.codigo})" end)
    |> Enum.join(", ")
  end


  # -------------------------------------------------------------------
  # R6. Mejor calidad

  defp generar_mensaje_r6(%{mejor_productor: nil}) do
    [
      generar_titulo("Reporte 6. Mejor calidad (grasa ponderada por litros)"),
      "  Ningún productor tiene al menos 3 entregas válidas.\n"
    ]
  end

  defp generar_mensaje_r6(r6) do
    mejor = r6.mejor_productor
    grasa_del_mejor = formatear_decimales(mejor.grasa_ponderada, 3)

    [
      generar_titulo("Reporte 6. Mejor calidad (grasa ponderada por litros)"),
      "  Mejor calidad: #{mejor.nombre} (#{mejor.codigo}) con #{grasa_del_mejor} %\n",
      "\n  Productor\tEntregas\tPonderada\tSimple\n",
      Util2.convertir_coleccion_mensaje(r6.clasificacion, fn productor ->
        ponderada = formatear_decimales(productor.grasa_ponderada, 3)
        simple = formatear_decimales(productor.grasa_simple, 3)
        "  #{productor.nombre}\t#{productor.cantidad_de_entregas}\t#{ponderada}\t#{simple}\n"
      end)
    ]
  end


  # -------------------------------------------------------------------
  # R7. Total pagado y costo por litro

  defp generar_mensaje_r7(r7) do
    [
      generar_titulo("Reporte 7. Totales de la semana"),
      "  Total pagado por el centro: #{formatear_pesos(r7.total_pagado)}\n",
      "  Litros recibidos: #{formatear_decimales(r7.litros_recibidos, 1)} L\n",
      "  Costo promedio por litro: #{formatear_pesos(r7.costo_promedio_por_litro)}\n"
    ]
  end


  # -------------------------------------------------------------------
  # R8. Productores con entregas en todos los tanques

  defp generar_mensaje_r8(productores) do
    [
      generar_titulo("Reporte 8. Productores con entregas en todos los tanques"),
      generar_lineas_de_productores_r8(productores)
    ]
  end

  defp generar_lineas_de_productores_r8([]), do: "  Ninguno.\n"

  defp generar_lineas_de_productores_r8(productores) do
    Util2.convertir_coleccion_mensaje(productores, fn productor -> "  #{productor.codigo} - #{productor.nombre}\n" end)
  end



  # FUNCIONES DE FORMATO

  defp generar_titulo(texto) do
    "\n#{@raya}\n#{texto}\n#{@raya}\n"
  end

  defp formatear_decimales(valor, decimales) do
    :erlang.float_to_binary(valor * 1.0, decimals: decimales)
  end

  defp formatear_pesos(valor) do
    "$#{formatear_decimales(valor, 0)}"
  end

  defp generar_si_o_no(true), do: "Sí"
  defp generar_si_o_no(false), do: "No"

  
end
