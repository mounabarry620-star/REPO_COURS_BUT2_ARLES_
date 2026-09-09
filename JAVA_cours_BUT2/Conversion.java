public class Conversion {
    public static void main(String[] args) {

        if (args.length == 1) {

            double c  = Double.parseDouble(args[0]);

            double f = (c * 9.0 / 5.0) + 32.0;

            System.out.println(c + " °C =" + f + "°F");
            
        } else {

            System.out.println("Erreur : vous devez passer exactement une valeur en paramètre.");
            System.out.println("Exemple d'utilisation : java Conversion 30");
        }
    }
}
