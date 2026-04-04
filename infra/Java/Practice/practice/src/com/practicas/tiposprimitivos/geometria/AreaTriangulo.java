package com.practicas.tiposprimitivos.geometria;

public class AreaTriangulo {
    public static void main(String[] args){
      try {
          double base = 16;
          double altura  = 90;
          if (altura == 0) {
              throw new ArithmeticException("La altura no puede ser");
          }
          double area = (base * altura)/ 2;
          System.out.println("Area; "+ area);
      }catch (ArithmeticException e){
          System.out.println("Error: "+ e.getMessage());
      }

    }
}
