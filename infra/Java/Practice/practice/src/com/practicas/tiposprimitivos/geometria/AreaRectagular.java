package com.practicas.tiposprimitivos.geometria;

public class AreaRectagular {
    public static void main(String[] args) {

        try {
            double largo = 5;
            double ancho = 12;

            if(largo < 0 || ancho < 0 ){
                throw new IllegalArgumentException("Los valores no debe ser igual a cero");
            }
            double area = largo * ancho;
            System.out.println("El area del cuadrado es: " + area);
        } catch (IllegalArgumentException e) {
            System.out.println(e.getMessage());
        }
    }
}