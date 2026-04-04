package com.practicas.tiposprimitivos.geometria;

public class AreaCuadrado {
    public static void main(String[] args){
        try{
        int lado = 5;
        if (lado < 0) {
            throw new Exception("EL lado debe ser mayor que cero ");
        }
        int resultado = lado * lado;
        System.out.println("el resultado es " + resultado);
    } catch (Exception e) {
        System.out.println(e.getMessage());
        }
    }
}
