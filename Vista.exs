# Integrantes: Luisa Hernández, Isabella Hincapié, Camila González

defmodule Vista do


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
  Imprime el reporte R1 de entregas rechazadas.
  """
  def imprimir_r1(r1) do
    [
      "\nReporte 1. Entregas rechazadas\n\n",
      generar_lineas_de_rechazadas(r1.entregas_rechazadas),
      "\nRechazos por motivo:\n",
      Util2.convertir_coleccion_mensaje(r1.cantidad_por_motivo, fn {motivo, cantidad} -> "  #{motivo}: #{cantidad}\n" end)
    ]
    |> Util2.mostrar(:mensaje)
  end

  @doc """
  Imprime el reporte R2 de ocupación de tanques.
  """
  def imprimir_r2(filas_de_tanques) do
    [
      "\nReporte 2. Ocupación de tanques (de mayor a menor)\n\n",
      "  Tanque\tLitros\tCapacidad\tOcupación\n",
      Util2.convertir_coleccion_mensaje(filas_de_tanques, fn tanque ->
        litros = formatear_decimales(tanque.litros_almacenados, 1)
        capacidad = formatear_decimales(tanque.capacidad, 0)
        ocupacion = formatear_decimales(tanque.porcentaje_ocupacion, 1)
        "  #{tanque.nombre}\t#{litros}\t#{capacidad}\t#{ocupacion} %\n"
      end)
    ]
    |> Util2.mostrar(:mensaje)
  end

  @doc """
  Imprime el reporte R3 de litros por día y meta diaria.
  """
  def imprimir_r3(r3) do
    meta = formatear_decimales(Parametros.meta_diaria(), 0)
    [
      "\nReporte 3. Litros recibidos por día (meta: #{meta} litros)\n\n",
      Util2.convertir_coleccion_mensaje(r3.detalle_por_dia, fn dia ->
        litros = formatear_decimales(dia.litros, 1)
        "  Día #{dia.dia}: #{litros} L - Meta alcanzada: #{generar_si_o_no(dia.alcanzo_meta)}\n"
      end),
      "\n  ¿Se cumplió la meta todos los días? #{generar_si_o_no(r3.cumplio_todos_los_dias)}\n",
      "  ¿Se cumplió la meta al menos un día? #{generar_si_o_no(r3.cumplio_al_menos_un_dia)}\n"
    ]
    |> Util2.mostrar(:mensaje)
  end

  @doc """
  Imprime el reporte R4 de liquidación de productores.
  """
  def imprimir_r4(liquidacion_ordenada) do
    productores_numerados = Enum.with_index(liquidacion_ordenada, 1)

    [
      "\nReporte 4. Liquidación de productores (por neto, de mayor a menor)\n\n",
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
    |> Util2.mostrar(:mensaje)
  end


   @doc """
  Imprime el reporte R5 de mayor entregador de cada día.
  """
  def imprimir_r5(r5) do
    [
      "\nReporte 5. Productor con más litros cada día\n\n",
      Util2.convertir_coleccion_mensaje(r5.detalle_por_dia, fn dia -> generar_linea_de_dia_r5(dia) end),
      generar_linea_de_primer_lugar_r5(r5.primer_lugar_en_mas_dias)
    ]
    |> Util2.mostrar(:mensaje)
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



  @doc """
  Imprime el reporte R6 de mejor calidad.
  """
  def imprimir_r6(%{mejor_productor: nil}) do
    [
      "\nReporte 6. Mejor calidad (grasa ponderada por litros)\n\n",
      "  Ningún productor tiene al menos 3 entregas válidas.\n"
    ]
    |> Util2.mostrar(:mensaje)
  end

  def imprimir_r6(r6) do
    mejor = r6.mejor_productor
    grasa_del_mejor = formatear_decimales(mejor.grasa_ponderada, 3)

    [
      "\nReporte 6. Mejor calidad (grasa ponderada por litros)\n\n",
      "  Mejor calidad: #{mejor.nombre} (#{mejor.codigo}) con #{grasa_del_mejor} %\n",
      "\n  Productor\tEntregas\tPonderada\tSimple\n",
      Util2.convertir_coleccion_mensaje(r6.clasificacion, fn productor ->
        ponderada = formatear_decimales(productor.grasa_ponderada, 3)
        simple = formatear_decimales(productor.grasa_simple, 3)
        "  #{productor.nombre}\t#{productor.cantidad_de_entregas}\t#{ponderada}\t#{simple}\n"
      end)
    ]
    |> Util2.mostrar(:mensaje)
  end



  @doc """
  Imprime el reporte R7 de total pagado y costo por litro.
  """
  def imprimir_r7(r7) do
    [
      "\nReporte 7. Totales de la semana\n\n",
      "  Total pagado por el centro: #{formatear_pesos(r7.total_pagado)}\n",
      "  Litros recibidos: #{formatear_decimales(r7.litros_recibidos, 1)} L\n",
      "  Costo promedio por litro: #{formatear_pesos(r7.costo_promedio_por_litro)}\n"
    ]
    |> Util2.mostrar(:mensaje)
  end



  @doc """
  Imprime el reporte R8 de productores con entregas
  en todos los tanques.
  """
  def imprimir_r8(productores) do
    [
      "\nReporte 8. Productores con entregas en todos los tanques\n\n",
      generar_lineas_de_productores_r8(productores)
    ]
    |> Util2.mostrar(:mensaje)
  end

  defp generar_lineas_de_productores_r8([]), do: "  Ninguno.\n"

  defp generar_lineas_de_productores_r8(productores) do
    Util2.convertir_coleccion_mensaje(productores, fn productor -> "  #{productor.codigo} - #{productor.nombre}\n" end)
  end



  @doc """
  Imprime la combinación de litros diarios con el centro vecino.
  """
  def imprimir_combinacion(propios, vecino, combinado) do
    dias = combinado |> Map.keys() |> Util2.ordenar(:asc)

    [
      "\nInvestigación. Combinación con el centro vecino (Map.merge/3)\n\n",
      "  Día\tPropio\tVecino\tCombinado\n",
      Util2.convertir_coleccion_mensaje(dias, fn dia ->
        propio = generar_valor_del_dia(propios, dia)
        del_vecino = generar_valor_del_dia(vecino, dia)
        total = formatear_decimales(combinado[dia], 1)
        "  #{dia}\t#{propio}\t#{del_vecino}\t#{total}\n"
      end)
    ]
    |> Util2.mostrar(:mensaje)
  end

  defp generar_valor_del_dia(mapa, dia) do
    if Map.has_key?(mapa, dia) do
      formatear_decimales(mapa[dia], 1)
    else
      "-"
    end
  end



  @doc """
  Imprime el comprobante de un productor, o avisa si el código no existe.
  """
  def imprimir_comprobante({:error, :productor_no_existe}, codigo) do
    Util2.mostrar("\nEl productor #{codigo} no existe.", :error)
  end

  def imprimir_comprobante({:ok, comprobante}, _codigo) do
    [
      "\nComprobante de pago\n",
      "  Productor: #{comprobante.nombre} (#{comprobante.codigo})\n\n",
      generar_lineas_de_comprobante(comprobante.detalle),
      "\n  Litros entregados: #{formatear_decimales(comprobante.litros, 1)} L\n",
      "  Total entregas: #{formatear_pesos(comprobante.valor_entregas)}\n",
      "  Total bonificaciones: #{formatear_pesos(comprobante.bonificaciones)}\n",
      "  Descuento por transporte: #{formatear_pesos(comprobante.transporte)}\n",
      "  Neto a pagar: #{formatear_pesos(comprobante.neto)}\n"
    ]
    |> Util2.mostrar(:mensaje)
  end

  defp generar_lineas_de_rechazadas([]), do: "  No hubo entregas rechazadas.\n"

  defp generar_lineas_de_rechazadas(entregas_rechazadas) do
    Util2.convertir_coleccion_mensaje(entregas_rechazadas, fn {entrega, motivo} -> "  #{inspect(entrega)}  ->  #{motivo}\n" end)
  end

  defp generar_lineas_de_comprobante([]), do: "  No tuvo entregas válidas en la semana.\n"

  defp generar_lineas_de_comprobante(detalle) do
    [
      "  Día\tLitros\tValor\tBonificación\n",
      Util2.convertir_coleccion_mensaje(detalle, fn dia ->
        litros = formatear_decimales(dia.litros, 1)
        valor = formatear_pesos(dia.valor)
        bonificacion = formatear_pesos(dia.bonificacion)
        "  #{dia.dia}\t#{litros}\t#{valor}\t#{bonificacion}\n"
      end)
    ]
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
