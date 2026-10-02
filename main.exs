# Integrantes: Luisa Hernández, Isabella Hincapié, Camila González
# Programa principal: validación, entrega adicional, reportes, centro vecino y comprobante.
# Ejecutar con:  elixir main.exs

Code.require_file("Util2.ex", __DIR__)
Code.require_file("parametros.exs", __DIR__)
Code.require_file("datos.exs", __DIR__)
Code.require_file("validacion.exs", __DIR__)
Code.require_file("liquidacion.exs", __DIR__)
Code.require_file("Reportes.exs", __DIR__)
Code.require_file("entrada.exs", __DIR__)
Code.require_file("Vista.exs", __DIR__)

defmodule Main do
  # Función principal del programa.
  def main do
    # Datos iniciales
    productores = Datos.productores()
    tanques = Datos.tanques()
    entregas = Datos.entregas()

    # 1. Separa las entregas en válidas y rechazadas
    {validas, rechazadas} = Validacion.clasificar(entregas, productores, tanques)

    # 2. Entrega adicional (antes de los reportes)
    {validas, rechazadas} = registrar_entrega_adicional(validas, rechazadas, productores, tanques)

    # 3. Liquidación y reportes R1 a R8
    liquidaciones = Liquidacion.liquidar(productores, validas)
    reportes = Reportes.generar_reportes(validas, rechazadas, productores, tanques, liquidaciones)
    Vista.imprimir_reportes(reportes)

    # 4. Investigación: combinar los litros diarios con los del centro vecino (Map.merge/3)
    vecino = Datos.centro_vecino()
    litros_por_dia = Reportes.calcular_litros_por_dia(validas)
    combinado = Reportes.combinar_con_vecino(litros_por_dia, vecino)
    Vista.imprimir_combinacion(litros_por_dia, vecino, combinado)

    # 5. Comprobante de un productor
    codigo =
      "\nIngrese el código del productor para el comprobante: "
      |> Util2.ingresar(:texto)
      |> String.upcase()
    Vista.imprimir_comprobante(Liquidacion.comprobante(codigo, productores, validas), codigo)
  end

  # Pide una entrega adicional, la revisa y la agrega a las válidas o a las rechazadas.
  def registrar_entrega_adicional(validas, rechazadas, productores, tanques) do
    Util2.mostrar("Ingrese una entrega adicional", :mensaje)
    Util2.mostrar("(productor;tanque;dia;litros;grasa)", :mensaje)
    texto = Util2.ingresar("o Enter para omitir: ", :texto)

    if texto == "" do
      Util2.mostrar("No se registró entrega adicional.", :mensaje)
      {validas, rechazadas}
    else
      case Entrada.parsear_entrega(texto) do
        {:error, :formato_invalido} ->
          Util2.mostrar("Entrada no registrada: {:error, :formato_invalido}", :error)
          {validas, rechazadas}

        {:ok, entrega} ->
          case Validacion.validar(entrega, productores, tanques) do
            {:ok, valida} ->
              Util2.mostrar("Entrega adicional aceptada.", :mensaje)
              {validas ++ [valida], rechazadas}

            {:error, motivo} ->
              Util2.mostrar("Entrega adicional rechazada: #{motivo}", :error)
              {validas, rechazadas ++ [{entrega, motivo}]}
          end
      end
    end
  end
end

Main.main()
