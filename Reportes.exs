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


 # FUNCIONES AUXILIARES:

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
      end)
  end

  defp crear_mapa_productores(productores) do
    Map.new(productores, fn productor -> {productor.codigo, productor.nombre} end)
  end

  defp crear_ficha_productor(codigo, mapa_productores) do
    %{codigo: codigo, nombre: Map.get(mapa_productores, codigo)}
  end

  # -------------------------------------------------------------------

  # R1. Entregas rechazadas

  @doc """
  R1: devuelve las entregas rechazadas con su motivo y la cantidad
  de rechazos por cada uno de los 5 motivos (los que no aparecen quedan en 0).
  """

  def calcular_r1(entregas_rechazadas) do

    frecuencia_motivo =
      entregas_rechazadas
      |> Enum.frequencies_by(fn {_entrega, motivo} -> motivo end)

    cantidad_por_motivo =
      for motivo <- @motivos do
        {
          motivo,
          Map.get(frecuencia_motivo, motivo, 0)
        }
      end

    %{
      entregas_rechazadas: entregas_rechazadas,
      cantidad_por_motivo: cantidad_por_motivo
    }
  end


  # -------------------------------------------------------------------

  # R2. Ocupación de tanques

  @doc """
  R2: litros almacenados por tanque y porcentaje de ocupación, ordenado de mayor a menor porcentaje.
  """
  def calcular_r2(entregas_validas, tanques) do

    litros_por_tanque =
      entregas_validas
      |> sumar_litros_agrupados_por(:tanque)

    filas_sin_ordenar =
      for tanque <- tanques do

        litros_almacenados = Map.get(litros_por_tanque, tanque.id, 0)
        porcentaje_ocupacion = litros_almacenados / tanque.capacidad * 100

        %{
          id: tanque.id,
          nombre: tanque.nombre,
          litros_almacenados: litros_almacenados,
          capacidad: tanque.capacidad,
          porcentaje_ocupacion: porcentaje_ocupacion
        }

      end

    filas_sin_ordenar
    |> ranking(campo: :porcentaje_ocupacion, orden: :desc, desempate: :id)

  end


  # -------------------------------------------------------------------

  # R3. Litros por día y meta diaria

  @doc """
  Devuelve un mapa con los litros de cada uno de los días,
  por ejemplo:
  %{1 => 1850.5, 2 => 0, ..., 6 => 2100}.
  Los días sin entregas quedan en 0.
  Pública porque se usa para el ejercicio de Map.merge/3.
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
  calcular_r3: litros recibidos cada día, si se alcanzó la meta diaria, y si se cumplió todos los días o al menos un día.
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
  calcular_r4: la liquidación ordenada por pago neto de mayor a menor. La numeración la agrega Vista.exs al imprimir.
  """
  def calcular_r4(liquidacion) do
    liquidacion
    |> ranking(campo: :neto, orden: :desc, desempate: :codigo)
  end





  # -------------------------------------------------------------------

  # R5. Mayor entregador de cada día

  @doc """
  calcular_r5: productor(es) con más litros cada día (si hay empate salen todos)
  y quién ocupó el primer lugar en más días.
  """

  def calcular_r5(entregas_validas, productores) do

    mapa_productores = crear_mapa_productores(productores)

    detalle_por_dia =
      for dia <- 1..Parametros.dias() do

        entregas_del_dia =
          entregas_validas
          |> Enum.filter(fn entrega -> entrega.dia == dia end)

        litros_por_productor =
          entregas_del_dia
          |> sumar_litros_agrupados_por(:productor)

        if map_size(litros_por_productor) == 0 do
          %{
            dia: dia,
            litros_del_lider: 0,
            productores_lideres: []
          }
        else
            litros_por_productor
            |> Map.values()
            |> Enum.max()

          codigos_lideres =
            for {codigo, litros} <- litros_por_productor,
                litros == litros_del_lider do
              codigo
            end

          productores_lideres =
            codigos_lideres
            |> Enum.sort()
            |> Enum.map(fn codigo -> crear_ficha_productor(codigo, mapa_productores) end)

          %{
            dia: dia,
            litros_del_lider: litros_del_lider,
            productores_lideres: productores_lideres
          }
        end
      end

    codigos_de_todos_los_lideres =
      detalle_por_dia
      |> Enum.flat_map(fn dia ->
        dia.productores_lideres
        |> Enum.map(fn lider -> lider.codigo end)
      end)

    dias_como_lider_por_productor =
      codigos_de_todos_los_lideres
      |> Enum.frequencies()

    primer_lugar_en_mas_dias =
      if map_size(dias_como_lider_por_productor) == 0 do
        %{
          dias_en_primer_lugar: 0,
          productores: []
        }
      else
        maximo_de_dias =
          dias_como_lider_por_productor
          |> Map.values()
          |> Enum.max()

        codigos_ganadores =
          for {codigo, cantidad_de_dias} <- dias_como_lider_por_productor,
              cantidad_de_dias == maximo_de_dias do
            codigo
          end

        fichas_ganadores =
          codigos_ganadores
          |> Enum.sort()
          |> Enum.map(fn codigo -> crear_ficha_productor(codigo, mapa_codigo_nombre) end)

        %{
          dias_en_primer_lugar: maximo_de_dias,
          productores: fichas_ganadores
        }
      end

    %{
      detalle_por_dia: detalle_por_dia,
      primer_lugar_en_mas_dias: primer_lugar_en_mas_dias
    }
  end


  # -------------------------------------------------------------------

  # R6. Mejor calidad

  @doc """
  calcular_r6: productor con mejor calidad entre quienes tienen al menos 3 entregas válidas.

  Fórmulas:
    grasa_ponderada = suma(grasa * litros) / suma(litros)
    grasa_simple    = suma(grasa) / cantidad_de_entregas

  """

  def calcular_r6(entregas_validas, productores) do

    mapa_codigo_nombre =
      crear_mapa_codigo_nombre(productores)

    entregas_por_productor =
      entregas_validas
      |> Enum.group_by(fn entrega -> entrega.productor end)

    candidatos =
      for {codigo, entregas} <- entregas_por_productor, length(entregas) >= 3 do

        cantidad_de_entregas =
          length(entregas)

        litros_totales =
          entregas
          |> Enum.map(fn entrega -> entrega.litros end)
          |> Enum.sum()

        suma_grasa_por_litros =
          entregas
          |> Enum.map(fn entrega -> entrega.grasa * entrega.litros end)
          |> Enum.sum()

        suma_grasa =
          entregas
          |> Enum.map(fn entrega -> entrega.grasa end)
          |> Enum.sum()

        %{
          codigo: codigo,
          nombre: Map.get(mapa_codigo_nombre, codigo),
          cantidad_de_entregas: cantidad_de_entregas,
          litros_totales: litros_totales,
          grasa_ponderada: suma_grasa_por_litros / litros_totales,
          grasa_simple: suma_grasa / cantidad_de_entregas
        }
      end

    clasificacion =
      candidatos
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


  # -------------------------------------------------------------------

  # R7. Total pagado y costo por litro

  @doc """
  calcular_r7: total pagado por el centro en la semana y costo promedio por litro.

  Fórmulas:
    total_pagado             = suma de los netos de todos los productores
    costo_promedio_por_litro = total_pagado / litros_recibidos
  """

  def calcular_r7(entregas_validas, liquidacion) do

    total_pagado =
      liquidacion
      |> Enum.map(fn productor -> productor.neto end)
      |> Enum.sum()

    litros_recibidos =
      entregas_validas
      |> Enum.map(fn entrega -> entrega.litros end)
      |> Enum.sum()

    costo_promedio_por_litro =
      if litros_recibidos > 0 do
        total_pagado / litros_recibidos
      else
        0
      end

    %{
      total_pagado: total_pagado,
      litros_recibidos: litros_recibidos,
      costo_promedio_por_litro: costo_promedio_por_litro
    }
  end


  # -------------------------------------------------------------------

  # R8. Productores con entregas en todos los tanques

  @doc """
  calcular_r8: productores con al menos una entrega válida en cada uno de los tanques.

  Usa MapSet (conjuntos) porque permite preguntar con subset?/2
  si todos los tanques están entre los que usó el productor.
  """

  def calcular_r8( entregas_validas, productores, tanques) do

    conjunto_de_todos_los_tanques =
      tanques
      |> Enum.map(fn tanque -> tanque.id end)
      |> MapSet.new()

    tanques_usados_por_productor =
      entregas_validas
      |> Enum.group_by(
        fn entrega -> entrega.productor end,
        fn entrega -> entrega.tanque end
      )

    productores
    |> Enum.filter(fn productor -> lista_de_tanques_usados =
        Map.get(
          tanques_usados_por_productor,
          productor.codigo,
          []
        )

      conjunto_de_tanques_usados =
        lista_de_tanques_usados
        |> MapSet.new()

      MapSet.subset?(
        conjunto_de_todos_los_tanques,
        conjunto_de_tanques_usados
      )
    end)
  end


end
