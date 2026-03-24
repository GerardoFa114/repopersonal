package com.practicas.tiposprimitivos;

public class AreaSuma {
    //Calcula los valores de la siguientes variables cuando a= 5 y  b= 8
    public static void main(String[] args) {
        try {
            int a = 5;
            int b = 8;
            int suma = a + b;

            System.out.println("Resultado: " + suma);

        } catch (Exception e) {
            System.out.print("Ocurrio un erroror en la operacion");
            System.out.print(e.getMessage());

        }
    }
}
