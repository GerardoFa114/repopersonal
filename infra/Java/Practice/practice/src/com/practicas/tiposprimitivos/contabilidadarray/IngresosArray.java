package com.practicas.tiposprimitivos.contabilidadarray;

public class IngresosArray {
    public static void main(String[] args){
        try {
            double [] ingresos = {1000, 2500, 1800};
            double total = 0;

            for(int i = 0; 1 < ingresos.length; i++){
                total += ingresos [1];
            }
            System.out.println("Total ingresos: "+ total);
        }catch(Exception e) {
            System.out.println("Error al sumar ingresos");
        }
    }
}
