# Integrantes: Luisa Hernández, Isabella Hincapié, Camila González

defmodule Reportes do

  # Mínimo de entregas válidas para entrar al reporte R6.
  @minimo_entregas_validas 3

  @motivos [
    :productor_desconocido,
    :tanque_desconocido,
    :dia_invalido,
    :litros_fuera_de_rango,
    :porcentaje_invalido
  ]

  @doc """
  Ordena una lista según un campo indicado y permite establecer
  el sentido del orden y un campo para desempatar.
  """
  def ranking(lista, opciones) do
    campo = Keyword.fetch!(opciones, :campo)
    orden = Keyword.get(opciones, :orden, :desc)
    desempate = Keyword.get(opciones, :desempate)

    lista_desempate =
      if desempate do
        lista
        |> Util2.ordenar(:asc, fn elemento -> Map.get(elemento, desempate) end)
      else
        lista
      end

    lista_desempate
    |> Util2.ordenar(orden, fn elemento -> Map.get(elemento, campo) end)
  end

  @doc """
  Genera todos los reportes de la semana utilizando las entregas
  válidas, rechazadas, productores, tanques y liquidación.
  """
  def generar_reportes(entregas_validas, entregas_rechazadas, productores, tanques, liquidacion) do
    %{
      r1: calcular_r1(entregas_rechazadas),
      r2: calcular_r2(entregas_validas, tanques),
      r3: calcular_r3(entregas_validas),
      r4: calcular_r4(liquidacion),
      r5: calcular_r5(entregas_validas, productores),
      r6: calcular_r6(entregas_validas, productores),
      r7: calcular_r7(entregas_validas, liquidacion),
      r8: calcular_r8(entregas_validas, productores, tanques)
    }
  end


  # FUNCIONES AUXILIARES

  defp sumar_litros_por_campo(entregas, campo_de_agrupacion) do
    Enum.reduce(
      entregas,
      %{},
      fn entrega, litros_acumulados ->
        grupo = Map.get(entrega, campo_de_agrupacion)

        Map.update(
          litros_acumulados,
          grupo,
          entrega.litros,
          fn litros_actuales -> litros_actuales + entrega.litros end
        )
      end
    )
  end

  defp sumar_litros(entregas) do
    Enum.reduce(entregas, 0, fn entrega, total -> total + entrega.litros end)
  end

  defp obtener_entregas_por(entregas, campo, valor) do
    Enum.filter(entregas, fn entrega -> Map.get(entrega, campo) == valor end)
  end


  # -------------------------------------------------------------------
  # R1. Entregas rechazadas

  @doc """
  R1: devuelve las entregas rechazadas con su motivo y la cantidad
  de rechazos por cada uno de los 5 motivos.
  Los motivos que no aparecen quedan en 0.
  """
  def calcular_r1(entregas_rechazadas) do
    cantidad_por_motivo =
      Enum.map(@motivos, fn motivo ->
         {motivo, contar_rechazos_del_motivo(entregas_rechazadas, motivo)}
      end)

    %{
      entregas_rechazadas: entregas_rechazadas,
      cantidad_por_motivo: cantidad_por_motivo
    }
  end

  defp contar_rechazos_del_motivo(entregas_rechazadas, motivo) do
    entregas_rechazadas
    |> Enum.filter(fn {_entrega, motivo_de_la_entrega} -> motivo_de_la_entrega == motivo end)
    |> length()
  end


  # -------------------------------------------------------------------
  # R2. Ocupación de tanques

  @doc """
  R2: calcula los litros almacenados por tanque y el porcentaje
  de ocupación, ordenados de mayor a menor porcentaje.
  """
  def calcular_r2(entregas_validas, tanques) do
    tanques
    |> Enum.map(fn tanque ->
      calcular_ocupacion_del_tanque(tanque, entregas_validas)
    end)
    |> ranking(
      campo: :porcentaje_ocupacion,
      orden: :desc,
      desempate: :id
    )
  end

  defp calcular_ocupacion_del_tanque(tanque, entregas_validas) do
    litros_por_tanque =
      sumar_litros_por_campo(entregas_validas, :tanque)

    litros_almacenados =
      Map.get(litros_por_tanque, tanque.id, 0)

    %{
      id: tanque.id,
      nombre: tanque.nombre,
      litros_almacenados: litros_almacenados,
      capacidad: tanque.capacidad,
      porcentaje_ocupacion: litros_almacenados / tanque.capacidad * 100
    }
  end


  # -------------------------------------------------------------------
  # R3. Litros por día y meta diaria

  @doc """
  Devuelve un mapa con los litros recibidos en cada uno de los días.
  Los días sin entregas quedan con valor 0.
  """
  def calcular_litros_por_dia(entregas_validas) do
    litros_iniciales =
      for dia <- 1..Parametros.dias(), into: %{} do
        {dia, 0}
      end

    Enum.reduce(
      entregas_validas,
      litros_iniciales,
      fn entrega, litros_acumulados ->
        Map.update(
          litros_acumulados,
          entrega.dia,
          entrega.litros,
          fn litros_actuales -> litros_actuales + entrega.litros end
        )
      end
    )
  end

  @doc """
  R3: calcula los litros recibidos cada día, indica si se alcanzó
  la meta diaria y determina si se cumplió todos los días o al menos un día.
  """
  def calcular_r3(entregas_validas) do
    meta_diaria =
      Parametros.meta_diaria()

    litros_por_dia =
      entregas_validas
      |> calcular_litros_por_dia()

    pares_dia_litros =
      litros_por_dia
      |> Map.to_list()
      |> Util2.ordenar(:asc, fn {dia, _litros} -> dia end)

    detalle_por_dia =
      for {dia, litros} <- pares_dia_litros do
        %{
          dia: dia,
          litros: litros,
          alcanzo_meta: litros >= meta_diaria
        }
      end

    cumplio_todos_los_dias =
      detalle_por_dia
      |> Enum.all?(fn dia -> dia.alcanzo_meta end)

    cumplio_al_menos_un_dia =
      detalle_por_dia
      |> Enum.any?(fn dia -> dia.alcanzo_meta end)

    %{
      detalle_por_dia: detalle_por_dia,
      cumplio_todos_los_dias: cumplio_todos_los_dias,
      cumplio_al_menos_un_dia: cumplio_al_menos_un_dia
    }
  end


  # -------------------------------------------------------------------
  # R4. Liquidación ordenada

  @doc """
  R4: ordena la liquidación de productores por el pago neto,
  de mayor a menor. La numeración se agrega al momento de imprimir.
  """
  def calcular_r4(liquidacion) do
    liquidacion
    |> ranking(campo: :neto, orden: :desc, desempate: :codigo)
  end


  # -------------------------------------------------------------------
  # R5. Mayor entregador de cada día

  @doc """
  R5: calcula el productor o productores con más litros cada día.
  Si existe empate, se incluyen todos los productores empatados.
  También determina quién ocupó el primer lugar en más días.
  """
  def calcular_r5(entregas_validas, productores) do
    detalle_por_dia =
      Enum.map(1..Parametros.dias(), fn dia ->
        calcular_lideres_del_dia(dia, entregas_validas, productores)
      end)

    %{
      detalle_por_dia: detalle_por_dia,
      primer_lugar_en_mas_dias:
        calcular_primer_lugar_en_mas_dias(detalle_por_dia, productores)
    }
  end

  defp calcular_lideres_del_dia(dia, entregas_validas, productores) do
    entregas_del_dia =
      obtener_entregas_por(entregas_validas, :dia, dia)

    totales_por_productor =
      sumar_litros_por_campo(entregas_del_dia, :productor)

    litros_por_productor =
      Enum.map(productores, fn productor ->
        litros =
          Map.get(totales_por_productor, productor.codigo, 0)

        %{
          codigo: productor.codigo,
          nombre: productor.nombre,
          litros: litros
        }
      end)

    litros_del_lider =
      litros_por_productor
      |> Enum.map(fn productor -> productor.litros end)
      |> Enum.max()

    %{
      dia: dia,
      litros_del_lider: litros_del_lider,
      productores_lideres:
        obtener_lideres(litros_por_productor, litros_del_lider)
    }
  end

  defp obtener_lideres(_litros_por_productor, 0), do: []

  defp obtener_lideres(litros_por_productor, litros_del_lider) do
    litros_por_productor
    |> Enum.filter(fn productor -> productor.litros == litros_del_lider end)
    |> ranking(campo: :codigo, orden: :asc)
  end

  defp calcular_primer_lugar_en_mas_dias(detalle_por_dia, productores) do
    dias_como_lider_por_productor =
      Enum.map(productores, fn productor ->
        dias_como_lider =
          detalle_por_dia
          |> Enum.filter(fn dia ->
            fue_lider_ese_dia?(dia, productor.codigo)
          end)
          |> length()

        %{
          codigo: productor.codigo,
          nombre: productor.nombre,
          dias_como_lider: dias_como_lider
        }
      end)

    maximo_de_dias =
      dias_como_lider_por_productor
      |> Enum.map(fn productor -> productor.dias_como_lider end)
      |> Enum.max()

    %{
      dias_en_primer_lugar: maximo_de_dias,
      productores:
        obtener_ganadores(dias_como_lider_por_productor, maximo_de_dias)
    }
  end

  defp obtener_ganadores(_dias_como_lider_por_productor, 0), do: []

  defp obtener_ganadores(dias_como_lider_por_productor, maximo_de_dias) do
    dias_como_lider_por_productor
    |> Enum.filter(fn productor -> productor.dias_como_lider == maximo_de_dias end)
    |> ranking(campo: :codigo, orden: :asc)
  end

  defp fue_lider_ese_dia?(dia, codigo_del_productor) do
    Enum.any?(dia.productores_lideres, fn lider -> lider.codigo == codigo_del_productor end)
  end


  # -------------------------------------------------------------------
  # R6. Mejor calidad

  @doc """
  R6: calcula la clasificación de productores con mejor calidad
  entre quienes tienen al menos 3 entregas válidas.

  Fórmulas:
    grasa_ponderada = suma(grasa * litros) / suma(litros)
    grasa_simple = suma(grasa) / cantidad_de_entregas

  Se guardan las dos medidas para poder compararlas.
  """
  def calcular_r6(entregas_validas, productores) do
    clasificacion =
      productores
      |> Enum.map(fn productor ->
        {
          productor,
          obtener_entregas_por(
            entregas_validas,
            :productor,
            productor.codigo
          )
        }
      end)
      |> Enum.filter(fn {_productor, entregas} ->
        length(entregas) >= @minimo_entregas_validas
      end)
      |> Enum.map(fn {productor, entregas} ->
        calcular_calidad_del_productor(productor, entregas)
      end)
      |> ranking(
        campo: :grasa_ponderada,
        orden: :desc,
        desempate: :codigo
      )

    %{
      clasificacion: clasificacion,
      mejor_productor: List.first(clasificacion)
    }
  end

  defp calcular_calidad_del_productor(productor, entregas) do
    cantidad_de_entregas =
      length(entregas)

    litros_totales =
      sumar_litros(entregas)

    suma_grasa_por_litros =
      entregas
      |> Enum.map(fn entrega ->
        entrega.grasa * entrega.litros
      end)
      |> Enum.sum()

    suma_grasa =
      entregas
      |> Enum.map(fn entrega -> entrega.grasa end)
      |> Enum.sum()

    %{
      codigo: productor.codigo,
      nombre: productor.nombre,
      cantidad_de_entregas: cantidad_de_entregas,
      litros_totales: litros_totales,
      grasa_ponderada:
        suma_grasa_por_litros / litros_totales,
      grasa_simple:
        suma_grasa / cantidad_de_entregas
    }
  end


  # -------------------------------------------------------------------
  # R7. Total pagado y costo por litro

  @doc """
  R7: calcula el total pagado por el centro durante la semana,
  los litros recibidos y el costo promedio por litro.

  Fórmulas:
    total_pagado = suma de los netos de todos los productores
    costo_promedio_por_litro = total_pagado / litros_recibidos
  """
  def calcular_r7(entregas_validas, liquidacion) do
    total_pagado =
      liquidacion
      |> Enum.map(fn productor -> productor.neto end)
      |> Enum.sum()

    litros_recibidos =
      sumar_litros(entregas_validas)

    %{
      total_pagado: total_pagado,
      litros_recibidos: litros_recibidos,
      costo_promedio_por_litro:
        calcular_costo_por_litro(total_pagado, litros_recibidos)
    }
  end

  defp calcular_costo_por_litro(_total_pagado, 0), do: 0

  defp calcular_costo_por_litro(total_pagado, litros_recibidos) do
    total_pagado / litros_recibidos
  end


  # -------------------------------------------------------------------
  # R8. Productores con entregas en todos los tanques

  @doc """
  R8: obtiene los productores que tienen al menos una entrega válida
  en cada uno de los tanques.
  """
  def calcular_r8(entregas_validas, productores, tanques) do
    Enum.filter(productores, fn productor ->
      entrego_en_todos_los_tanques?(productor, entregas_validas, tanques)
    end)
  end

  defp entrego_en_todos_los_tanques?(productor, entregas_validas, tanques) do
    Enum.all?(tanques, fn tanque ->
      entrego_en_el_tanque?(productor, tanque, entregas_validas)
    end)
  end

  defp entrego_en_el_tanque?(productor, tanque, entregas_validas) do
    Enum.any?(
      entregas_validas,
      fn entrega ->
        entrega.productor == productor.codigo and
          entrega.tanque == tanque.id
      end
    )
  end

end
