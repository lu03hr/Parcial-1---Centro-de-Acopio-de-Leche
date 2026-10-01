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

end
end
Main..main()
