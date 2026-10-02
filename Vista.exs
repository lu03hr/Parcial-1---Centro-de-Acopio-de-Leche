# Integrantes: Luisa Hernández, Isabella Hincapié, Camila González

defmodule Vista do

  @raya "============================================================"

  @doc """
  Imprime los ocho reportes en orden.
  """
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

  @doc """
  Genera e imprime el reporte R1 de entregas rechazadas.
  """
  def imprimir_r1(r1) do
    r1
    |> generar_mensaje_r1()
    |> Util2.mostrar(:mensaje)
  end

  @doc """
  Genera e imprime el reporte R2 de ocupación de tanques.
  """
  def imprimir_r2(r2) do
    r2
    |> generar_mensaje_r2()
    |> Util2.mostrar(:mensaje)
  end

  @doc """
  Genera e imprime el reporte R3 de litros por día y meta diaria.
  """
  def imprimir_r3(r3) do
    r3
    |> generar_mensaje_r3()
    |> Util2.mostrar(:mensaje)
  end

  @doc """
  Genera e imprime el reporte R4 de liquidación de productores.
  """
  def imprimir_r4(r4) do
    r4
    |> generar_mensaje_r4()
    |> Util2.mostrar(:mensaje)
  end

  @doc """
  Genera e imprime el reporte R5 de mayor entregador de cada día.
  """
  def imprimir_r5(r5) do
    r5
    |> generar_mensaje_r5()
    |> Util2.mostrar(:mensaje)
  end

  @doc """
  Genera e imprime el reporte R6 de mejor calidad.
  """
  def imprimir_r6(r6) do
    r6
    |> generar_mensaje_r6()
    |> Util2.mostrar(:mensaje)
  end

  @doc """
  Genera e imprime el reporte R7 de total pagado y costo por litro.
  """
  def imprimir_r7(r7) do
    r7
    |> generar_mensaje_r7()
    |> Util2.mostrar(:mensaje)
  end

  @doc """
  Genera e imprime el reporte R8 de productores con entregas
  en todos los tanques.
  """
  def imprimir_r8(r8) do
    r8
    |> generar_mensaje_r8()
    |> Util2.mostrar(:mensaje)
  end

  # -------------------------------------------------------------------
  # GENERAR R1. Entregas rechazadas

  @doc """
  Genera el mensaje que se muestra para el reporte R1.
  """
  defp generar_mensaje_r1(r1) do
    [
      generar_titulo("Reporte 1. Entregas rechazadas"),
      generar_lineas_de_rechazadas(r1.entregas_rechazadas),
      "\nRechazos por motivo:\n",
      Util2.convertir_coleccion_mensaje(r1.cantidad_por_motivo, fn {motivo, cantidad} -> "  #{motivo}: #{cantidad}\n" end)
    ]
  end

  @doc """
  Genera el texto correspondiente cuando no hubo entregas rechazadas.
  """
  defp generar_lineas_de_rechazadas([]), do: "  No hubo entregas rechazadas.\n"

  @doc """
  Genera una línea de texto para cada entrega rechazada,
  mostrando la entrega y su motivo.
  """
  defp generar_lineas_de_rechazadas(entregas_rechazadas) do
    Util2.convertir_coleccion_mensaje(entregas_rechazadas, fn {entrega, motivo} -> "  #{inspect(entrega)}  ->  #{motivo}\n" end)
  end


  # -------------------------------------------------------------------
  # GENERAR R2. Ocupación de tanques

  @doc """
  Genera el mensaje del reporte R2 mostrando litros,
  capacidad y porcentaje de ocupación de cada tanque.
  """
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

  @doc """
  Genera el mensaje del reporte R3 con los litros recibidos
  y el cumplimiento de la meta diaria.
  """
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

  @doc """
  Genera el mensaje del reporte R4 mostrando la liquidación
  ordenada y numerada de los productores.
  """
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

  @doc """
  Genera el mensaje del reporte R5 mostrando el productor
  con más litros de cada día.
  """
  defp generar_mensaje_r5(r5) do
    [
      generar_titulo("Reporte 5. Productor con más litros cada día"),
      Util2.convertir_coleccion_mensaje(r5.detalle_por_dia, fn dia -> generar_linea_de_dia_r5(dia) end),
      generar_linea_de_primer_lugar_r5(r5.primer_lugar_en_mas_dias)
    ]
  end

  @doc """
  Genera el texto del reporte R5 cuando no hubo entregas válidas
  durante un día.
  """
  defp generar_linea_de_dia_r5(%{productores_lideres: [], dia: dia}) do
    "  Día #{dia}: sin entregas válidas\n"
  end

  @doc """
  Genera el texto del reporte R5 con los productores líderes de un día.
  """
  defp generar_linea_de_dia_r5(dia) do
    nombres = generar_texto_de_productores(dia.productores_lideres)
    litros = formatear_decimales(dia.litros_del_lider, 1)
    "  Día #{dia.dia}: #{nombres} con #{litros} L\n"
  end

  @doc """
  Genera el texto correspondiente cuando ningún productor
  ocupó el primer lugar.
  """
  defp generar_linea_de_primer_lugar_r5(%{productores: []}) do
    "\n  Nadie ocupó el primer lugar.\n"
  end

  @doc """
  Genera el texto indicando los productores que ocuparon
  el primer lugar durante más días.
  """
  defp generar_linea_de_primer_lugar_r5(primer_lugar) do
    nombres = generar_texto_de_productores(primer_lugar.productores)
    "\n  Primer lugar en más días (#{primer_lugar.dias_en_primer_lugar} días): #{nombres}\n"
  end

  @doc """
  Convierte las fichas de productores en un texto con su nombre y código.
  """
  defp generar_texto_de_productores(fichas) do
    fichas
    |> Enum.map(fn ficha -> "#{ficha.nombre} (#{ficha.codigo})" end)
    |> Enum.join(", ")
  end


  # -------------------------------------------------------------------
  # R6. Mejor calidad

  @doc """
  Genera el mensaje del reporte R6 cuando ningún productor
  tiene al menos 3 entregas válidas.
  """
  defp generar_mensaje_r6(%{mejor_productor: nil}) do
    [
      generar_titulo("Reporte 6. Mejor calidad (grasa ponderada por litros)"),
      "  Ningún productor tiene al menos 3 entregas válidas.\n"
    ]
  end

  @doc """
  Genera el mensaje del reporte R6 mostrando el productor
  con mejor calidad y la clasificación de los demás productores.
  """
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

  @doc """
  Genera el mensaje del reporte R7 mostrando el total pagado,
  los litros recibidos y el costo promedio por litro.
  """
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

  @doc """
  Genera el mensaje del reporte R8 mostrando los productores
  que realizaron entregas en todos los tanques.
  """
  defp generar_mensaje_r8(productores) do
    [
      generar_titulo("Reporte 8. Productores con entregas en todos los tanques"),
      generar_lineas_de_productores_r8(productores)
    ]
  end

  @doc """
  Genera el texto correspondiente cuando no hay productores
  con entregas en todos los tanques.
  """
  defp generar_lineas_de_productores_r8([]), do: "  Ninguno.\n"

  @doc """
  Genera una línea de texto para cada productor que realizó
  entregas en todos los tanques.
  """
  defp generar_lineas_de_productores_r8(productores) do
    Util2.convertir_coleccion_mensaje(productores, fn productor -> "  #{productor.codigo} - #{productor.nombre}\n" end)
  end



 # FUNCIONES DE FORMATO

  @doc """
  Genera el título de cada reporte utilizando una línea separadora.
  """
  defp generar_titulo(texto) do
    "\n#{@raya}\n#{texto}\n#{@raya}\n"
  end

  @doc """
  Convierte un número a texto con la cantidad de decimales indicada.
  """
  defp formatear_decimales(valor, decimales) do
    :erlang.float_to_binary(valor * 1.0, decimals: decimales)
  end

  @doc """
  Formatea un valor como cantidad de dinero.
  """
  defp formatear_pesos(valor) do
    "$#{formatear_decimales(valor, 0)}"
  end

  @doc """
  Convierte un valor booleano en "Sí" o "No".
  """
  defp generar_si_o_no(true), do: "Sí"
  defp generar_si_o_no(false), do: "No"


end
