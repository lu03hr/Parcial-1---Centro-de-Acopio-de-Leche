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
    productores_por_codigo = Validacion.indexar_productores(productores)
    tanques_por_id = Validacion.indexar_tanques(tanques)

     entregas = Datos.entregas()
    {validas, rechazadas} = Validacion.clasificar(entregas, productores_por_codigo, tanques_por_id)
    Vista.resumen_carga(length(entregas), length(validas), length(rechazadas))


    {validas, rechazadas} =
      registrar_entrega_adicional(validas, rechazadas, productores_por_codigo, tanques_por_id)


       liquidaciones = Liquidacion.liquidar(productores, validas)
    nombres = Map.new(productores, fn p -> {p.codigo, p.nombre} end)
    datos_r3 = Reportes.r3(validas)

     Vista.r1(Reportes.r1(rechazadas))
    Vista.r2(Reportes.r2(tanques, validas))
    Vista.r3(datos_r3)
    Vista.r4(Reportes.r4(liquidaciones))
    Vista.r5(Reportes.r5(validas), nombres)
    Vista.r6(Reportes.r6(productores, validas))
    Vista.r7(Reportes.r7(liquidaciones))
    Vista.r8(Reportes.r8(productores, tanques, validas))

end
end
Main..main()
