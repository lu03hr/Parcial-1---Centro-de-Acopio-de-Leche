Code.require_file("Util2.ex", __DIR__)
Code.require_file("parametros.exs", __DIR__)
Code.require_file("datos.exs", __DIR__)
Code.require_file("validacion.exs", __DIR__)
Code.require_file("liquidacion.exs", __DIR__)
Code.require_file("reportes.exs", __DIR__)
Code.require_file("entrada.exs", __DIR__)
Code.require_file("vista.exs", __DIR__)

defmodule Main do
  def main do
    productores = Datos.productores()
    tanques = Datos.tanques()
    productores_por_codigo = productores
    tanques_por_id = tanques

    entregas = Datos.entregas()

    {validas, rechazadas} =
      Validacion.clasificar(entregas, productores_por_codigo, tanques_por_id)

    Vista.resumen_carga(length(entregas), length(validas), length(rechazadas))

    {validas, rechazadas} =
      registrar_entrega_adicional(validas, rechazadas, productores_por_codigo, tanques_por_id)

    liquidaciones = Liquidacion.liquidar(productores, validas)
    nombres = Map.new(for p <- productores, do: {p.codigo, p.nombre})
    datos_r3 = Reportes.r3(validas)

    Vista.r1(Reportes.r1(rechazadas))
    Vista.r2(Reportes.r2(tanques, validas))
    Vista.r3(datos_r3)
    Vista.r4(Reportes.r4(liquidaciones))
    Vista.r5(Reportes.r5(validas), nombres)
    Vista.r6(Reportes.r6(productores, validas))
    Vista.r7(Reportes.r7(liquidaciones))
    Vista.r8(Reportes.r8(productores, tanques, validas))

    vecino = Datos.centro_vecino()
    combinado = Reportes.combinar_con_vecino(datos_r3.litros_diarios, vecino)
    Vista.combinacion(datos_r3.litros_diarios, vecino, combinado)

    codigo = String.upcase(leer_linea("\nIngrese el código del productor para el comprobante: "))
    Vista.comprobante(Liquidacion.comprobante(codigo, productores_por_codigo, validas), codigo)
  end

  def registrar_entrega_adicional(validas, rechazadas, productores_por_codigo, tanques_por_id) do
    Util2.mostrar("Ingrese una entrega adicional", :mensaje)
    Util2.mostrar("(productor;tanque;dia;litros;grasa)", :mensaje)
    texto = leer_linea("o Enter para omitir: ")

    if texto == "" do
      Util2.mostrar("No se registró entrega adicional.", :mensaje)
      {validas, rechazadas}
    else
      case Entrada.parsear_entrega(texto) do
        {:error, :formato_invalido} ->
          Util2.mostrar("Entrada no registrada: {:error, :formato_invalido}", :mensaje)
          {validas, rechazadas}

        {:ok, entrega} ->
          case Validacion.validar(entrega, productores_por_codigo, tanques_por_id) do
            {:ok, valida} ->
              Util2.mostrar("Entrega adicional aceptada.", :mensaje)
              {validas ++ [valida], rechazadas}

            {:error, motivo} ->
              Util2.mostrar("Entrega adicional rechazada: #{motivo}", :mensaje)
              {validas, rechazadas ++ [{entrega, motivo}]}
          end
      end
    end
  end

  defp leer_linea(mensaje) do
    case IO.gets(mensaje) do
      :eof -> ""
      {:error, _razon} -> ""
      linea -> String.trim(linea)
    end
  end
end

Main..main()
