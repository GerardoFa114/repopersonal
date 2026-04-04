package com.practicas.tiposprimitivos.contabilidadarray;

public class ValidarIngresos {
    public static void main (String[] args){
        try{
            double[] ingresos = {1000, -5000, -2000};

            for( int i = 0; i < ingresos.length; i++) {
                if (ingresos [i] < 0) {
                    throw new IllegalArgumentException("ingreso negatico en posicion: "+ i);
                }
              }
            System.out.println("todos los ingresos son validos");

            }catch (IllegalArgumentException e) {
            System.out.println(e.getMessage());
        }
    }
}
